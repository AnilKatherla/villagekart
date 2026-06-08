// lib/features/search/widgets/group_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.name,
    required this.icon,
    required Color backgroundColor,
  });
  final String name;
  final String icon;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = icon.startsWith('http');

    return Column(
      children: [
        Container(
          width: 56,
          height: 54,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFFBF5FF), Color(0xFFF1F8FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [BoxShadow(color: Colors.white, offset: Offset(0, 1))],
          ),
          child: ClipOval(
            child: isNetworkImage
                ? CachedNetworkImage(
                    imageUrl: icon,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) {
                      return _buildPlaceholder(name);
                    },
                    placeholder: (context, url) {
                      return _buildPlaceholder(name);
                    },
                  )
                : Image.asset(
                    icon,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(name);
                    },
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.black,

            fontWeight: FontWeight.w400,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String categoryName) {
    final firstLetter = categoryName.isNotEmpty ? categoryName[0] : 'C';

    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// import '../../../../core/theme/colors.dart';

// class GroupCard extends StatelessWidget {
//   const GroupCard({super.key, required this.name, required this.icon});
//   final String name;
//   final String icon;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: 56,
//           height: 56,
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [Color(0xFFFBF5FF), Color(0xFFF1F8FF)],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//             boxShadow: [
//               BoxShadow(color: Colors.white, offset: Offset(0, 1)),
//             ],
//           ),
//           child: Image.asset(icon),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           name,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 12, color: AppColors.black, 
//             fontWeight: FontWeight.w400,),
//         ),
//       ],
//     );
//   }
// }