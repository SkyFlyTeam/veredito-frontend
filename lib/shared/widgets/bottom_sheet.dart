import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBottomSheet extends StatefulWidget {
	final WidgetBuilder bodyBuilder;
	final double maxHeightFactor;
	final double heightBuffer;
	final Color backgroundColor;
	final Color borderColor;
	final BorderRadius borderRadius;
	final bool showScrollbar;

	const AppBottomSheet({
		super.key,
		required this.bodyBuilder,
		this.maxHeightFactor = 0.8,
		this.heightBuffer = 36,
		this.backgroundColor = AppColors.blue800,
		this.borderColor = AppColors.gray200,
		this.borderRadius = const BorderRadius.vertical(
			top: Radius.circular(28),
		),
		this.showScrollbar = false,
	});

	static Future<T?> show<T>(
		BuildContext context, {
		required WidgetBuilder bodyBuilder,
		double maxHeightFactor = 0.8,
		double heightBuffer = 36,
		Color backgroundColor = AppColors.blue800,
		Color borderColor = AppColors.gray200,
		BorderRadius borderRadius = const BorderRadius.vertical(
			top: Radius.circular(28),
		),
		bool showScrollbar = false,
	}) {
		return showModalBottomSheet<T>(
			context: context,
			backgroundColor: Colors.transparent,
			isScrollControlled: true,
			builder: (_) => AppBottomSheet(
				bodyBuilder: bodyBuilder,
				maxHeightFactor: maxHeightFactor,
				heightBuffer: heightBuffer,
				backgroundColor: backgroundColor,
				borderColor: borderColor,
				borderRadius: borderRadius,
				showScrollbar: showScrollbar,
			),
		);
	}

	@override
	State<AppBottomSheet> createState() => _AppBottomSheetState();
}

class _AppBottomSheetState extends State<AppBottomSheet> {
	final GlobalKey _bodyMeasureKey = GlobalKey();
	final ScrollController _scrollController = ScrollController();

	double? _bodyHeight;
	bool _didScheduleMeasurement = false;

	@override
	void initState() {
		super.initState();
		_scheduleMeasureBodyHeight();
	}

	@override
	void dispose() {
		_scrollController.dispose();
		super.dispose();
	}

	@override
	void didUpdateWidget(covariant AppBottomSheet oldWidget) {
		super.didUpdateWidget(oldWidget);
		_scheduleMeasureBodyHeight();
	}

	void _scheduleMeasureBodyHeight() {
		if (_didScheduleMeasurement) return;
		_didScheduleMeasurement = true;
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_didScheduleMeasurement = false;
			_measureBodyHeight();
		});
	}

	void _measureBodyHeight() {
		if (!mounted) return;

		final renderObject = _bodyMeasureKey.currentContext?.findRenderObject();
		if (renderObject is! RenderBox || !renderObject.hasSize) return;

		final measuredHeight = renderObject.size.height;
		if (_bodyHeight == null || (_bodyHeight! - measuredHeight).abs() > 0.5) {
			setState(() {
				_bodyHeight = measuredHeight;
			});
		}
	}

	Widget _buildBody(BuildContext context) {
		return NotificationListener<SizeChangedLayoutNotification>(
			onNotification: (_) {
				_scheduleMeasureBodyHeight();
				return false;
			},
			child: SizeChangedLayoutNotifier(
				child: widget.bodyBuilder(context),
			),
		);
	}

	Widget _buildMeasuredBody(BuildContext context) {
		return KeyedSubtree(
			key: _bodyMeasureKey,
			child: _buildBody(context),
		);
	}

	Widget _buildSheetContainer(BuildContext context, {required bool scrollable}) {
		final screenWidth = MediaQuery.sizeOf(context).width;

		return SizedBox(
			width: screenWidth,
			child: Container(
				decoration: BoxDecoration(
					color: widget.backgroundColor,
					borderRadius: widget.borderRadius,
					border: Border(
						top: BorderSide(color: widget.borderColor, width: 1),
					),
				),
				child: Column(
					mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						const _BottomSheetHandle(),
						if (scrollable)
							Expanded(
								child: widget.showScrollbar
										? Scrollbar(
												controller: _scrollController,
												thumbVisibility: true,
												child: SingleChildScrollView(
													controller: _scrollController,
													child: _buildMeasuredBody(context),
												),
											)
										: SingleChildScrollView(
												controller: _scrollController,
												child: _buildMeasuredBody(context),
											)
							)
						else
							_buildMeasuredBody(context),
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final screenHeight = MediaQuery.sizeOf(context).height;
		final maxSheetHeight = screenHeight * widget.maxHeightFactor;
		final shouldConstrainHeight =
				_bodyHeight == null || _bodyHeight! + widget.heightBuffer > maxSheetHeight;

		return Stack(
			children: [
				if (shouldConstrainHeight)
					ConstrainedBox(
						constraints: BoxConstraints(maxHeight: maxSheetHeight),
						child: _buildSheetContainer(context, scrollable: true),
					)
				else
					_buildSheetContainer(context, scrollable: false),
			],
		);
	}
}

class _BottomSheetHandle extends StatelessWidget {
	const _BottomSheetHandle();

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: const EdgeInsets.all(16),
				child: Container(
					width: 32,
					height: 4,
					decoration: BoxDecoration(
						color: AppColors.gray200,
						borderRadius: BorderRadius.circular(100),
					),
				),
			),
		);
	}
}
