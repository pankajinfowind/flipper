import 'package:flipper/data/main_database.dart';
import 'package:flipper/domain/redux/app_state.dart';
import 'package:flipper/generated/l10n.dart';
import 'package:flipper/model/cart.dart';
import 'package:flipper/presentation/home/common_view_model.dart';
import 'package:flipper/routes/router.gr.dart';
import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';

import '../theme.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    @required this.scaffoldKey,
    @required this.sideOpenController,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final ValueNotifier<bool> sideOpenController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CommonViewModel>(
      distinct: true,
      converter: CommonViewModel.fromStore,
      builder: (context, vm) {
        List<Cart> carts = [];

        return SafeArea(
          top: true,
          child: Container(
            height: AppTheme.appBarSize,
            child: Row(
              children: <Widget>[
                _hamburger(),
                SizedBox(
                  height: 120,
                  width: 60,
                ),
                Align(
                  alignment: Alignment.center,
                  child: StreamBuilder(
                    stream: vm.database.cartDao.getCarts(),
                    builder:
                        (context, AsyncSnapshot<List<CartTableData>> snapshot) {
                      print(snapshot.data);
                      var quantity = snapshot.data == null
                          ? 0
                          : snapshot.data.fold(0, (a, b) => a + b.count);
                      return FlatButton(
                        onPressed: () {
                          Router.navigator.pushNamed(
                            Router.cartDetailsScreen,
                            arguments: CartDetailsScreenArguments(
                              carts: snapshot.data,
                            ),
                          );
                        },
                        child: Text(
                          snapshot.data == null
                              ? S.of(context).noSale
                              : S.of(context).currentSale +
                                  "[" +
                                  quantity.toString() +
                                  "]",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 19,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _hamburger() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          scaffoldKey.currentState.openDrawer();
        },
        child: Container(
          width: AppTheme.appBarSize,
          height: AppTheme.appBarSize,
          child: Center(
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Image.asset(
                  "assets/graphics/menu_icon.png", //TODO: change it to our icon later.
                  width: 25,
                  height: 25,
                ),
                Visibility(
                  visible: true,
                  child: Positioned(
                    top: -3,
                    right: -5,
                    height: 12,
                    width: 12,
                    child: Image.asset(
                      "assets/graphics/updates_indicator_white.png",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppTheme.appBarSize);
}