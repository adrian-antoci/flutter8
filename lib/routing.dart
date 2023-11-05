import 'package:flutter/material.dart';
import 'package:flutter8/screens/home/home_screen.dart';
import 'package:flutter8/screens/login_screen.dart';
import 'package:flutter8/screens/post_screen.dart';
import 'package:flutter8/screens/profile_screen.dart';
import 'package:flutter8/screens/welcome_screen.dart';
import 'package:flutter8/services/firebase.dart';
import 'package:flutter8/theme/layout.dart';
import 'package:flutter8/theme/responsive.dart';
import 'package:go_router/go_router.dart';
import 'package:sa3_liquid/liquid/plasma/plasma.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
final NextPageController _nextPageController = NextPageController();

GoRouter routerConfig({
  required BuildContext context,
  required SharedPreferences sharedPrefs,
}) =>
    GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      redirect: (BuildContext context, GoRouterState state) async {
        bool isTermsAgreed = sharedPrefs.getBool("is_terms_agreed") ?? false;
        if (!isTermsAgreed) {
          return '/welcome';
        }
        await firebaseInit();
        return null;
      },
      routes: [
        GoRoute(
          path: '/welcome',
          builder: (BuildContext context, GoRouterState state) {
            return const WelcomeScreenWidget();
          },
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            if (isMobile(context)) {
              return child;
            }
            return _shellRouteWidget(context: context, child: child);
          },
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) {
                return HomeScreenWidget(
                  nextPageController: _nextPageController,
                );
              },
            ),
            GoRoute(
              path: '/post',
              builder: (BuildContext context, GoRouterState state) {
                return const PostScreenWidget();
              },
            ),
            GoRoute(
              path: '/login',
              builder: (BuildContext context, GoRouterState state) {
                return const LoginScreenWidget();
              },
            ),
            GoRoute(
              path: '/profile',
              builder: (BuildContext context, GoRouterState state) {
                var user = state.extra as Map;
                return ProfileScreenWidget(user['id'], user['name'], user['avatar']);
              },
            ),
          ],
        ),
      ],
    );

Widget _shellRouteWidget({required BuildContext context, required Widget child}) => Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          PlasmaRenderer(
            type: PlasmaType.bubbles,
            particles: 50,
            color: Colors.white.withOpacity(0.08),
            blur: 0,
            size: 0.04,
            speed: 0.29,
            offset: 0,
            blendMode: BlendMode.screen,
            particleType: ParticleType.atlas,
            variation1: 0.31,
            variation2: 0.3,
            variation3: 0.13,
            rotation: 1.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox.square(dimension: 60),
              Container(
                padding: const EdgeInsets.all(10),
                constraints: isMobile(context) ? null : const BoxConstraints(maxWidth: 550),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: child,
                ),
              ),
              Container(
                padding: EdgeInsets.all(layoutPadding / 4),
                margin: EdgeInsets.all(layoutPadding / 4),
                child: SizedBox.square(
                  dimension: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(5),
                        backgroundColor: Colors.white.withOpacity(0.4)),
                    onPressed: () => _nextPageController.onNextPage(),
                    child: const Icon(Icons.arrow_downward, color: Colors.white, size: 30),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );

class NextPageController {
  VoidCallback? listener;

  void addListener(listener) => this.listener = listener;

  void onNextPage() {
    if (listener != null) {
      listener!();
    }
  }
}
