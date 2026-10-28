import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/remote_or_asset_image.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../domain/models/service_model.dart';

class ServiceReviewCard extends StatelessWidget {
  const ServiceReviewCard({super.key, required this.review});

  final ServiceReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(source: review.avatarUrl, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.date,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              RatingStars(rating: review.rating),
            ],
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: AppColors.slate600,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ],
          if (review.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.imagePaths
                  .map((imagePath) => _ReviewImage(imagePath: imagePath))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 12});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
          child: SvgPicture.asset(
            'assets/icons/detail_review_star.svg',
            width: size,
            height: size,
            colorFilter: index < rating
                ? null
                : const ColorFilter.mode(AppColors.slate200, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _ReviewImage extends StatelessWidget {
  const _ReviewImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: RemoteOrAssetImage(
        source: imagePath,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
      ),
    );
  }
}
