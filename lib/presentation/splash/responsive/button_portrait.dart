import 'package:flipper/generated/l10n.dart';
import 'package:flipper/presentation/splash/popup.dart';
import 'package:flipper/presentation/splash/popup_content.dart';
import 'package:flutter/material.dart';

class ButtonPortrait extends StatefulWidget {
  const ButtonPortrait({Key key, this.showBottomSheetCallback})
      : super(key: key);
  final VoidCallback showBottomSheetCallback;
  @override
  _ButtonPortraitState createState() => _ButtonPortraitState();
}

class _ButtonPortraitState extends State<ButtonPortrait> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 2,
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
            ),
            Container(
              color: Colors.blue,
              child: SizedBox(
                width: 380,
                height: 60,
                child: FlatButton(
                  onPressed: widget.showBottomSheetCallback,
                  color: Colors.blue,
                  child:const Text(
                    'Create Account',
                    style:  TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              height: 20,
            ),
            Container(
              color: Colors.white,
              child: SizedBox(
                width: 380,
                height: 60,
                child: OutlineButton(
                  color: Colors.blue,
                  child:const Text(
                    'Sign in',
                    style:  TextStyle(color: Colors.blue),
                  ),
                  onPressed: widget.showBottomSheetCallback,
                ),
              ),
            ),
            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  showPopup(BuildContext context, Widget widget, {BuildContext popupContext}) {
    Navigator.push(
      context,
      PopupLayout(
        top: 30,
        left: 30,
        right: 30,
        bottom: 50,
        child: PopupContent(
          content: Scaffold(
            resizeToAvoidBottomPadding: false,
            body: widget,
          ),
        ),
      ),
    );
  }
}