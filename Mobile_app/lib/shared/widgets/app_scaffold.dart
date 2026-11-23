import 'package:flutter/material.dart';
import 'state_widgets.dart';

/// Standard Screen Scaffold Wrapper for Quick Money.
/// Handles consistent state display (Loading, Empty, Error, Success).
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final ScreenState state;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final VoidCallback? onRetry;
  final String? errorMessage;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.state = ScreenState.success,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = true,
    this.onRetry,
    this.errorMessage,
    this.backgroundColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: (title != null || titleWidget != null)
          ? AppBar(
              title: titleWidget ?? Text(title!),
              actions: actions,
              bottom: bottom,
              automaticallyImplyLeading: showBackButton,
            )
          : null,
      body: SafeArea(
        child: _buildBody(),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildBody() {
    switch (state) {
      case ScreenState.loading:
        return const StateLoading();
      case ScreenState.empty:
        return const StateEmpty();
      case ScreenState.error:
        return StateErrorWidget(
          message: errorMessage ?? 'An error occurred',
          onRetry: onRetry,
        );
      case ScreenState.offline:
        return StateErrorWidget(
          message: 'No internet connection',
          onRetry: onRetry,
        );
      case ScreenState.success:
        return body;
    }
  }
}

