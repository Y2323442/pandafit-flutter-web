import 'package:flutter/material.dart';
import 'video_detail_page.dart';

class VideoListPage extends StatelessWidget {
  const VideoListPage({super.key});

  static const Color bgColor = Color(0xFFF1F8E9);
  static const Color mainGreen = Color(0xFFD1E683);
  static const Color darkCard = Color(0xFF1A1C1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Training Videos", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 传入不同的延迟，实现排队弹出的效果
          _buildVideoItem(context, 0, "Fat Burning Cardio", "25 Min", "assets/images/running.jpg"),
          _buildVideoItem(context, 1, "Abs Shredding", "15 Min", "assets/images/fire.jpg"),
          _buildVideoItem(context, 2, "Full Body Stretch", "10 Min", "assets/images/basketball.jpg"),
        ],
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, int index, String title, String time, String img) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: index * 150)),
      builder: (context, snapshot) {
        bool isVisible = snapshot.connectionState == ConnectionState.done;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: isVisible ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              // 【核心修复】：强制限制透明度在 0 到 1 之间，防止崩溃
              opacity: value.clamp(0.0, 1.0).toDouble(), 
              child: Transform.translate(
                offset: Offset(0, 40 * (1 - value)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => VideoDetailPage(title: title, img: img))
                    );
                  },
                  child: Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      // 这里的背景图如果加载失败也会导致黑屏，请确保路径正确
                      image: DecorationImage(
                        image: AssetImage(img), 
                        fit: BoxFit.cover, 
                        opacity: 0.8
                      ),
                      color: Colors.black,
                    ),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.play_circle_fill, color: mainGreen, size: 60)),
                        Positioned(
                          bottom: 20, left: 25,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("$time • High Intensity", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
