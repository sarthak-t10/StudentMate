import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';

/// Responsive wrapper that automatically provides ResponsiveHelper context.
/// Use this to wrap complex layouts that need responsive calculations.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper responsive)
      builder;

  const ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return builder(context, responsive);
  }
}

/// Responsive container that constrains content width on large screens
/// and adapts padding based on device size.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  final Alignment alignment;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return SingleChildScrollView(
      child: Padding(
        padding: padding ?? EdgeInsets.all(responsive.horizontalPadding),
        child: Align(
          alignment: alignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? responsive.maxContentWidth,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Responsive grid that automatically calculates columns based on screen size.
/// Good for displaying cards, items, or module tiles.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final double? spacing;
  final bool shrinkWrap;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.crossAxisCount,
    this.childAspectRatio,
    this.spacing,
    this.shrinkWrap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final cols = crossAxisCount ?? responsive.cardGridColumns;
    final aspect = childAspectRatio ?? responsive.cardAspectRatio;
    final space = spacing ?? responsive.spacingMedium;

    return GridView.count(
      crossAxisCount: cols,
      childAspectRatio: aspect,
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: space,
      mainAxisSpacing: space,
      children: children,
    );
  }
}

/// Responsive text that scales font size based on screen size.
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    Key? key,
    this.baseStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final style = baseStyle ?? Theme.of(context).textTheme.bodyMedium;
    final responsiveStyle = style?.copyWith(
      fontSize: style.fontSize != null
          ? responsive.scale(style.fontSize!)
          : responsive.bodyFontSize,
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive heading that automatically scales based on screen size.
class ResponsiveHeading extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;

  const ResponsiveHeading(
    this.text, {
    Key? key,
    this.fontSize,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final size = fontSize ?? responsive.titleFontSize;

    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: fontWeight,
        color: color ?? AppColors.textPrimaryColor,
      ),
      textAlign: textAlign,
    );
  }
}

/// Responsive spacer that scales based on screen size.
class ResponsiveSpacer extends StatelessWidget {
  final double factor; // Multiplier for responsive spacing
  final bool vertical;

  const ResponsiveSpacer({
    Key? key,
    this.factor = 1.0,
    this.vertical = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final space = responsive.spacingMedium * factor;

    return vertical ? SizedBox(height: space) : SizedBox(width: space);
  }
}

/// Responsive card wrapper that provides consistent styling and sizing.
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final pad = padding ?? EdgeInsets.all(responsive.spacingMedium);
    final radius = borderRadius ?? responsive.radiusMedium;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        padding: pad,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: boxShadow ?? [AppShadow.light],
        ),
        child: child,
      ),
    );
  }
}

/// Responsive list view that adapts to screen size and orientation.
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const ResponsiveListView({
    Key? key,
    required this.children,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final pad = padding ?? EdgeInsets.all(responsive.horizontalPadding);

    return ListView(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: pad,
      scrollDirection: scrollDirection,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            SizedBox(height: responsive.spacingMedium),
        ],
      ],
    );
  }
}

/// Responsive two-column layout that stacks on small screens
/// and displays side-by-side on larger screens.
class ResponsiveTwoColumn extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double? spacing;

  const ResponsiveTwoColumn({
    Key? key,
    required this.left,
    required this.right,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final space = spacing ?? responsive.spacingMedium;

    if (responsive.isSmallPhone) {
      return Column(
        children: [
          left,
          SizedBox(height: space),
          right,
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          SizedBox(width: space),
          Expanded(child: right),
        ],
      );
    }
  }
}

/// Responsive padding that adapts to screen size.
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final bool all;
  final bool horizontal;
  final bool vertical;
  final double? customFactor;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.all = true,
    this.horizontal = false,
    this.vertical = false,
    this.customFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final factor = customFactor ?? 1.0;

    if (all) {
      return Padding(
        padding: EdgeInsets.all(responsive.horizontalPadding * factor),
        child: child,
      );
    } else if (horizontal) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.horizontalPadding * factor,
        ),
        child: child,
      );
    } else if (vertical) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: responsive.verticalPadding * factor,
        ),
        child: child,
      );
    }
    return child;
  }
}

/// Responsive button that scales size based on screen dimensions.
class ResponsiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final bool fullWidth;

  const ResponsiveButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.style,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: style ??
          ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacingMedium,
              vertical: responsive.spacingSmall,
            ),
            minimumSize: Size(0, responsive.buttonHeight),
          ),
      child: Text(label),
    );

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
