import 'package:flipper/couchbase.dart';
import 'package:flipper/data/main_database.dart';
import 'package:flipper/data/respositories/branch_repository.dart';
import 'package:flipper/data/respositories/business_repository.dart';
import 'package:flipper/data/respositories/general_repository.dart';
import 'package:flipper/data/respositories/user_repository.dart';
import 'package:flipper/domain/redux/app_actions/actions.dart';
import 'package:flipper/domain/redux/branch/branch_actions.dart';
import 'package:flipper/domain/redux/business/business_actions.dart';
import 'package:flipper/model/branch.dart';
import 'package:flipper/model/business.dart';
import 'package:flipper/model/category.dart';
import 'package:flipper/model/hint.dart';
import 'package:flipper/model/item.dart';
import 'package:flipper/model/order.dart';
import 'package:flipper/model/unit.dart';
import 'package:flipper/model/user.dart';
import 'package:flipper/routes/router.gr.dart';
import 'package:flipper/util/flitter_color.dart';
import 'package:flipper/util/logger.dart';
import 'package:flipper/util/util.dart';
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:redux/redux.dart";

import '../app_state.dart';
import 'auth_actions.dart';

/// Authentication Middleware
/// LogIn: Logging user in
/// LogOut: Logging user out
/// VerifyAuthenticationState: Verify if user is logged in

List<Middleware<AppState>> createAuthenticationMiddleware(
  UserRepository userRepository,
  BusinessRepository businessRepository,
  BranchRepository branchRepository,
  GeneralRepository generalRepository,
  GlobalKey<NavigatorState> navigatorKey,
) {
  return [
    TypedMiddleware<AppState, VerifyAuthenticationState>(_verifyAuthState(
        userRepository,
        businessRepository,
        branchRepository,
        generalRepository,
        navigatorKey)),
    TypedMiddleware<AppState, LogIn>(_authLogin(userRepository, navigatorKey)),
    TypedMiddleware<AppState, LogOutAction>(
        _authLogout(userRepository, navigatorKey)),
    TypedMiddleware<AppState, AfterLoginAction>(_verifyAuthState(userRepository,
        businessRepository, branchRepository, generalRepository, navigatorKey)),
  ];
}

void Function(Store<AppState> store, dynamic action, NextDispatcher next)
    _verifyAuthState(
  UserRepository userRepository,
  BusinessRepository businessRepository,
  BranchRepository branchRepository,
  GeneralRepository generalRepository,
  GlobalKey<NavigatorState> navigatorKey,
) {
  return (store, action, next) async {
    next(action);
    if (userRepository.checkAuth(store) == null) {
      Router.navigator.pushNamed(Router.login);
      store.dispatch(Unauthenticated);
      return;
    }

    loadClientDb(store);
    //end of streaming new order to part of apps's store
    UserTableData user = await userRepository.checkAuth(store);

    TabsTableData tab = await generalRepository.getTab(store);

    List<ItemTableData> items = await generalRepository.getItems(store);

    List<UnitTableData> unitsList = await generalRepository.getUnits(store);

    List<CategoryTableData> categoryList =
        await generalRepository.getCategories(store);

    List<BranchTableData> branch = await branchRepository.getBranches(store);

    final _user = User(
      (u) => u
        ..id = user.id
        ..bearerToken = user.bearerToken
        ..username = user.username
        ..refreshToken = user.refreshToken
        ..status = user.status
        ..avatar = user.avatar
        ..email = user.email,
    );

    dispatchCurrentBranchHint(branch, store);

    List<Branch> branches = buildBranchList(branch);

    List<Unit> units = buildUnitList(unitsList);

    loadProducts(items, store, unitsList);

    List<Category> categories = loadSystemCategories(categoryList);

    //set focused Unit
    store.dispatch(UnitR(units));

    store.dispatch(CategoryAction(categories));

    store.dispatch(OnBranchLoaded(branches: branches));

    store.dispatch(OnAuthenticated(user: _user));

    //setActive branch.
    dispatchCurrentBranch(branch, store);

    //create app actions for saving state,or create.
    await createAppActions(store);
    //start by creating a draft order it it does not exist
    await createTemporalOrder(generalRepository, store, user);

    //set current active business to be used throughout the entire app transaction
    getBusinesses(store, user);
    //end of setting current active business.
    // Logger.d("Successfully loaded the app");

    dispatchFocusedTab(tab, store);

    //end setting active branch.
    //create custom category if does not exist
    await createSystemCustomCategory(generalRepository, store);

    //if no reason found then create app defaults reasons
    await createSystemStockReasons(store);
    //create custom item if does not exist
    await Util.createCustomItem(store, "custom");
    await generateAppColors(generalRepository, store);

    _createCustomCategory(store);
    _cleanApp(store);
    //branch
  };
}

void dispatchCurrentBranchHint(
    List<BranchTableData> branch, Store<AppState> store) {
  Hint hint = Hint((b) => b
    ..type = HintType.Branch
    ..name = branch[0].name);

  store.dispatch(OnHintLoaded(hint: hint));
}

List<Branch> buildBranchList(List<BranchTableData> branch) {
  List<Branch> branches = [];
  branch.forEach((b) => {
        branches.add(
          Branch(
            (bu) => bu
              ..name = b.name
              ..id = b.id,
          ),
        )
      });
  return branches;
}

List<Unit> buildUnitList(List<UnitTableData> unitsList) {
  List<Unit> units = [];
  unitsList.forEach((b) => {
        units.add(Unit((u) => u
          ..name = b.name
          ..branchId = b.businessId
          ..businessId = b.businessId
          ..focused = b.focused
          ..id = b.id))
      });
  return units;
}

List<Category> loadSystemCategories(List<CategoryTableData> categoryList) {
  List<Category> categories = [];
  categoryList.forEach((c) => {
        categories.add(
          Category(
            (u) => u
              ..name = c.name
              ..focused = c.focused
              ..branchId = u.branchId ?? 0
              ..id = c.id,
          ),
        )
      });
  return categories;
}

void dispatchCurrentBranch(
    List<BranchTableData> branch, Store<AppState> store) {
  for (var i = 0; i < branch.length; i++) {
    if (branch[i].isActive) {
      store.dispatch(
        OnCurrentBranchAction(
          branch: Branch(
            (b) => b
              ..id = branch[i].id
              ..name = branch[i].name
              ..isActive = branch[i].isActive
              ..description = "desc",
          ),
        ),
      );
    }
  }
}

Future createSystemCustomCategory(
    GeneralRepository generalRepository, Store<AppState> store) async {
  await generalRepository.insertCustomCategory(
    store,
    //ignore: missing_required_param
    CategoryTableData(
        branchId: store.state.branch.id, focused: false, name: 'custom'),
  );
}

void dispatchFocusedTab(TabsTableData tab, Store<AppState> store) {
  final currentTab = tab == null ? 0 : tab.tab;
  store.dispatch(
    CurrentTab(tab: currentTab),
  );
}

Future generateAppColors(
    GeneralRepository generalRepository, Store<AppState> store) async {
  List<String> colors = [
    "#d63031",
    "#0984e3",
    "#e84393",
    "#2d3436",
    "#6c5ce7",
    "#74b9ff",
    "#ff7675",
    "#a29bfe"
  ];
  //insert default colors for the app
  for (var i = 0; i < 8; i++) {
    //create default color items if does not exist
    await generalRepository.insertOrUpdateColor(
        store,
        //ignore: missing_required_param
        ColorTableData(isActive: false, name: colors[i]));
  }
}

Future createSystemStockReasons(Store<AppState> store) async {
  List<ReasonTableData> reasons =
      await store.state.database.reasonDao.getReasons();
  if (reasons.length == 0) {
    await store.state.database.reasonDao.insert(
        //ignore:missing_required_param
        ReasonTableData(name: 'Stock Received', action: 'Received'));
    await store.state.database.reasonDao
        //ignore:missing_required_param
        .insert(ReasonTableData(name: 'Lost', action: 'Lost'));
    await store.state.database.reasonDao
        //ignore:missing_required_param
        .insert(ReasonTableData(name: 'Thief', action: 'Thief'));
    await store.state.database.reasonDao
        //ignore:missing_required_param
        .insert(ReasonTableData(name: 'Damaged', action: 'Damaged'));
    await store.state.database.reasonDao.insert(
        //ignore:missing_required_param
        ReasonTableData(name: 'Inventory Re-counted', action: 'Re-counted'));
    await store.state.database.reasonDao.insert(
        //ignore:missing_required_param
        ReasonTableData(name: 'Restocked Return', action: 'Restocked Return'));
    await store.state.database.reasonDao
        //ignore:missing_required_param
        .insert(ReasonTableData(name: 'Sold', action: 'Sold'));
    await store.state.database.reasonDao.insert(
        //ignore:missing_required_param
        ReasonTableData(name: 'Transferred', action: 'Transferred'));

    await store.state.database.reasonDao
        //ignore:missing_required_param
        .insert(ReasonTableData(name: 'Canceled', action: 'Canceled'));
  }
}

void loadProducts(List<ItemTableData> items, Store<AppState> store,
    List<UnitTableData> unitsList) {
  List<Item> itemList = [];

  items.forEach(
    (i) => itemList.add(
      Item(
        (v) => v
          ..name = i.name
          ..branchId = i.branchId
          ..unitId = i.unitId
          ..id = i.id
          ..color = i.color
          ..price = 0
          ..categoryId = i.categoryId,
      ),
    ),
  );

  store.dispatch(ItemLoaded(items: itemList));
  unitsList.forEach((c) => {
        if (c.focused)
          {
            store.dispatch(
              CurrentUnit(
                unit: Unit(
                  (u) => u
                    ..id = c.id
                    ..name = c.name
                    ..focused = c.focused
                    ..businessId = c.businessId ?? 0
                    ..branchId = c.branchId ?? 0,
                ),
              ),
            )
          }
      });
}

Future createAppActions(Store<AppState> store) async {
  ActionsTableData actionAction =
      await store.state.database.actionsDao.getActionBy('save');

  ActionsTableData saveItem =
      await store.state.database.actionsDao.getActionBy('saveItem');
  if (saveItem == null) {
    await store.state.database.actionsDao.insert(
        //ignore:missing_required_param
        ActionsTableData(name: 'saveItem', isLocked: true));
  }
  if (actionAction == null) {
    await store.state.database.actionsDao.insert(
        //ignore:missing_required_param
        ActionsTableData(name: 'save', isLocked: true));
  }
}

Future createTemporalOrder(GeneralRepository generalRepository,
    Store<AppState> store, UserTableData user) async {
  OrderTableData order =
      await generalRepository.createDraftOrderOrReturnExistingOne(store);
  //broadcast order to be used later when creating a sale
  if (order != null) {
    store.dispatch(
      OrderCreated(
        order: Order(
          (o) => o
            ..status = order.status
            ..id = order.id
            ..userId = user.id
            ..branchId = order.branchId
            ..orderNote = order.orderNote
            ..orderNUmber = order.orderNUmber
            ..supplierId = order.supplierId
            ..subTotal = order.subTotal
            ..discountAmount = order.discountAmount
            ..supplierInvoiceNumber = order.supplierInvoiceNumber
            ..deliverDate = order.deliverDate
            ..discountRate = order.discountRate
            ..taxRate = order.taxRate
            ..taxAmount = order.taxAmount
            ..cashReceived = order.cashReceived
            ..saleTotal = order.saleTotal
            ..userId = order.userId
            ..customerSaving = order.customerSaving
            ..paymentId = order.paymentId
            ..orderNote = order.orderNote
            ..status = order.status
            ..customerChangeDue = order.customerChangeDue,
        ),
      ),
    );
  }
}

void getBusinesses(Store<AppState> store, user) async {
  List<Business> businesses = await CouchBase(shouldInitDb: false)
      .getDocumentByDocId(docId: 'businesses', T: Business);

  for (var i = 0; i < businesses.length; i++) {
    if (businesses[i].active) {
      store.dispatch(
        ActiveBusinessAction(
          Business(
            (b) => b
              ..id = businesses[i].id
              ..active = businesses[i].active
              ..name = businesses[i].name
              ..type = BusinessType.NORMAL
              ..hexColor = FlipperColors.defaultBusinessColor
              ..abbreviation = businesses[i].abbreviation
              ..image = "image_null",
          ),
        ),
      );
    }
  }
  store.dispatch(OnBusinessLoaded(business: businesses));
  if (businesses.length == 0 || user == null) {
    Router.navigator.pushNamed(Router.signUpScreen);
    return;
  } else {
    Router.navigator.pushNamed(Router.dashboard);
  }
}

void loadClientDb(Store<AppState> store) {
  //todo: load db from sqlite.
  store.dispatch(OnDbLoaded(name: 'lagrace'));
}

void _createCustomCategory(Store<AppState> store) async {
  CategoryTableData category = await store.state.database.categoryDao
      .getCategoryNameAndBranch("custom", store.state.branch.id);
  if (category == null) {
    await store.state.database.categoryDao.insert(
        //ignore:missing_required_param
        CategoryTableData(
            name: "custom", branchId: store.state.branch.id, focused: true));
  }
}

void _cleanApp(Store<AppState> store) async {
  ItemTableData item = await store.state.database.itemDao
      .getItemByName(name: 'tmp', branchId: store.state.branch.id);

  if (item == null) return;

  Util.deleteItem(store, item.name, item.id);
}

void Function(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) _authLogout(
  UserRepository userRepository,
  GlobalKey<NavigatorState> navigatorKey,
) {
  return (store, action, next) async {
    next(action);
    try {
      await userRepository.logOut();
      store.dispatch(OnLogoutSuccess());
    } catch (e) {
      Logger.w("Failed logout", e: e);
      store.dispatch(OnLogoutFail(e));
    }
  };
}

void Function(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) _authLogin(
  UserRepository userRepository,
  GlobalKey<NavigatorState> navigatorKey,
) {
  return (store, action, next) async {
    next(action);
  };
}
