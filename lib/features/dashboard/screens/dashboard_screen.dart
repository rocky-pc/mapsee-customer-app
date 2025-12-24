import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:stackfood_multivendor/features/cart/screens/cart_screen.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/congratulation_dialogue.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/registration_success_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/menu/screens/menu_screen.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/screens/order_screen.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/address_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:stackfood_multivendor/features/dashboard/widgets/running_order_view_widget.dart';
import 'package:stackfood_multivendor/features/favourite/screens/favourite_screen.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/common/widgets/cart_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_dialog_widget.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  final bool fromSplash;
  const DashboardScreen(
      {super.key, required this.pageIndex, this.fromSplash = false});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  bool _canExit = GetPlatform.isWeb ? true : false;
  late bool _isLogin;
  bool active = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();

    if (_isLogin) {
      if (Get.find<SplashController>().configModel!.loyaltyPointStatus! &&
          Get.find<LoyaltyController>().getEarningPint().isNotEmpty &&
          !ResponsiveHelper.isDesktop(Get.context)) {
        Future.delayed(
            const Duration(seconds: 1),
                () => showAnimatedDialog(
                Get.context!, const CongratulationDialogue()));
      }
      Get.find<OrderController>().getRunningOrders(1, notify: false);
    }

    _pageIndex = widget.pageIndex;
    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      HomeScreen(key: const ValueKey(0)),
      FavouriteScreen(key: const ValueKey(1)),
      CartScreen(fromNav: true, key: const ValueKey(2)),
      OrderScreen(key: const ValueKey(3)),
      MenuScreen(key: const ValueKey(4))
    ];

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
          }
          if (!ResponsiveHelper.isDesktop(context)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
          }
          _canExit = true;
          Timer(const Duration(seconds: 2), () {
            _canExit = false;
          });
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false, // Prevents keyboard from pushing up the navbar

        body: Column(
          children: [
            Expanded(
              child: GetBuilder<OrderController>(builder: (orderController) {
                List<OrderModel> runningOrder =
                orderController.runningOrderList != null
                    ? orderController.runningOrderList!
                    : [];

                List<OrderModel> reversOrder = List.from(runningOrder.reversed);

                return ExpandableBottomSheet(
                  background: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _screens,
                  ),
                  persistentContentHeight: 100,
                  onIsContractedCallback: () {
                    if (!orderController.showOneOrder) {
                      orderController.showOrders();
                    }
                  },
                  onIsExtendedCallback: () {
                    if (orderController.showOneOrder) {
                      orderController.showOrders();
                    }
                  },
                  enableToggle: true,
                  expandableContent: (ResponsiveHelper.isDesktop(context) ||
                      !_isLogin ||
                      orderController.runningOrderList == null ||
                      orderController.runningOrderList!.isEmpty ||
                      !orderController.showBottomSheet)
                      ? const SizedBox()
                      : Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      if (orderController.showBottomSheet) {
                        orderController.showRunningOrders();
                      }
                    },
                    child: RunningOrderViewWidget(
                        reversOrder: reversOrder,
                        onMoreClick: () {
                          if (orderController.showBottomSheet) {
                            orderController.showRunningOrders();
                          }
                          _setPage(3);
                        }),
                  ),
                );
              }),
            ),

            CustomBottomNavBar(
                selectedIndex: _pageIndex,
                onItemTapped: _setPage
            ),
          ],
        ),
      ),
    );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}