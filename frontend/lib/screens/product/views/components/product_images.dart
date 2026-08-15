import 'package:flutter/material.dart';
import '/components/network_image_with_loader.dart';

import '../../../../constants.dart';

class ProductImages extends StatefulWidget {
  const ProductImages({
    super.key,
    required this.images,
  });

  final List<String> images;

  @override
  State<ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    _controller = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return SliverToBoxAdapter(
        child: AspectRatio(
          aspectRatio: 1,
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious * 2),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.image_outlined, size: 48),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              onPageChanged: (pageNum) {
                setState(() {
                  _currentPage = pageNum;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: defaultPadding),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(defaultBorderRadious * 2),
                  ),
                  child: NetworkImageWithLoader(widget.images[index]),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                height: 20,
                bottom: 24,
                right: MediaQuery.of(context).size.width * 0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Row(
                    children: List.generate(
                      widget.images.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          right: index == widget.images.length - 1
                              ? 0
                              : defaultPadding / 4,
                        ),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(index == _currentPage ? 1 : 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
