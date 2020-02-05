import 'package:flipper/domain/redux/app_state.dart';
import 'package:flipper/presentation/home/common_view_model.dart';
import 'package:flipper/util/HexColor.dart';
import 'package:flipper/util/flitter_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class PayableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CommonViewModel>(
      distinct: true,
      converter: CommonViewModel.fromStore,
      builder: (context, vm) {
        return Container(
          width: 380,
          height: 60,
          color: HexColor(FlipperColors.blue),
          child: Row(
            children: <Widget>[
              SizedBox(width: 40),
              SizedBox(
                height: 120,
                child: FlatButton(
                  color: HexColor(FlipperColors.blue),
                  onPressed: () {},
                  child: Text(
                    "Tickets",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 40),
              SizedBox(
                height: 120,
                child: FlatButton(
                  color: HexColor(FlipperColors.blue),
                  onPressed: () {},
                  child: Text(
                    "Charge Frw0.00",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}