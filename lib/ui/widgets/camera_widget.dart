import 'dart:io';

import 'package:Linez/models/location_model.dart';
import 'package:camera/camera.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../blocs/line_image/line_image_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../constants.dart';
import '../../globals.dart';
import '../../resources/services/database_service.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
  super.key,
  required this.camera,
  required this.id,
  required this.location
  });

  final CameraDescription camera;
  final String id;
  final LocationModel location;

  @override
  TakePictureScreenState createState() => TakePictureScreenState(id: id, location: location);
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final LocationModel location;

  final String id;

  TakePictureScreenState({required this.id, required this.location});
  /*
      // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;
   */

  @override
  void initState() {
    super.initState();
    if(!UserData.admin) {
      FirebaseAnalytics.instance
          .setCurrentScreen(
          screenName: 'TakePicturePage'
      );
      FirebaseAnalytics.instance.logEvent(
        name: 'pageView',
        parameters: {
          'page': 'TakePicturePage',
        },
      );
    }
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: false,
    );
    _controller.setFlashMode(FlashMode.off);

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.setFlashMode(FlashMode.off);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(Constants.linezBlue),
          centerTitle: true,
          title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'BerkshiresWash', fontSize: MediaQuery.of(context).size.width * .07),),
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.height * .1,
        width: MediaQuery.of(context).size.height * .1,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Color(Constants.submitButtonBlue),
            // Provide an onPressed callback.
            onPressed: () async {
              // Take the Picture in a try / catch block. If anything goes wrong,
              // catch the error.
              try {
                // Ensure that the camera is initialized.
                await _initializeControllerFuture;

                // Attempt to take a picture and get the file `image`
                // where it was saved.
                await _controller.setFlashMode(FlashMode.off);
                print("Flash mode ${_controller.value.flashMode}");
                final image = await _controller.takePicture();

                if (!mounted) return;

                // If the picture was taken, display it on a new screen.
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      // Pass the automatically generated path to
                      // the DisplayPictureScreen widget.
                      imagePath: image.path, id: id, location: location,
                    ),
                  ),
                );
              } catch (e) {
                // If an error occurs, log the error to the console.
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ),

    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String id;
  final LocationModel location;

  const DisplayPictureScreen({super.key, required this.imagePath, required this.id, required this.location});

  Widget _buildTimeErrorDialog(int hour, int day, BuildContext context) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text((day < 4)
              ? "It's a weekday bozo, there's no line out here."
              : (hour > 2 && hour < 6)
              ? "It's too late to report a line dummy. Submit your line estimate between 8:00pm and 2:00am."
              : "It's too early to report a line dummy. Submit your line estimate between 8:00pm and 2:00am."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.linezBlue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildIntervalErrorDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("You can only report the same bar every hour."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.linezBlue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildLocationErrorDialog(bool locEnabled, BuildContext context, {bool locImprecise = false}) {
    return new AlertDialog(
      title: const Text('Not so fast!'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (locImprecise) ? Text("You must have precise location tracking enabled") :
          Text(locEnabled ? "You have to be close to the bar to report a line." : "You must enable precise location tracking before reporting a line."),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Color(Constants.linezBlue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(Constants.linezBlue),
        centerTitle: true,
        title: Text("Linez", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'BerkshiresWash', fontSize: MediaQuery.of(context).size.width * .07),),
        automaticallyImplyLeading: false,
        leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(children: [
        MultiBlocListener(
          listeners: [
            BlocListener<LineImageBloc, LineImageState>(
                listener: (context, state) {
                  if(state is LineImageLoading) {
                    context.loaderOverlay.show();
                  }
                  else if(state is LineImageSubmitted) {
                    context.loaderOverlay.hide();
                    DatabaseService().incrementTickets().then((value) => context.read<ProfileBloc>().add(GetProfileEvent()));
                    int count = 0;
                    Navigator.of(context).popUntil((_) => count++ >= 3);
                  }
                  else if(state is LineImageIntervalError) {
                    context.loaderOverlay.hide();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildIntervalErrorDialog(context));
                  }
                  else if (state is LineImageTimeError) {
                    context.loaderOverlay.hide();
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildTimeErrorDialog(state.hour, state.weekday, context));
                  }
                  else if (state is LineImageLocationError) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildLocationErrorDialog(true, context));
                  }
                  else if (state is LineImageImpreciseLocationError) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildLocationErrorDialog(false, context, locImprecise: true));
                  }
                  else if (state is LineImageNoLocationError) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildLocationErrorDialog(false, context));
                  }
                  else {
                    context.loaderOverlay.hide();
                    print("error");
                  }
                } )],
          child: Container(width: 0, height: 0,),),
        Align(
          alignment: FractionalOffset.bottomCenter,
          child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * .03),
            child: Container(
              width: MediaQuery.of(context).size.width * .4,
              height: MediaQuery.of(context).size.width * .15,
              child: ElevatedButton(
                child: Text("Submit", style: TextStyle(fontSize: MediaQuery.of(context).size.width * .07),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(Constants.submitButtonBlue),
                ), onPressed: () {
              context.read<LineImageBloc>().add(LineImageSubmit(imagePath: imagePath, id: id, location: location.position));
          },
          ),))
        ),
        Image.file(File(imagePath)),
      ],)
    );
  }
}