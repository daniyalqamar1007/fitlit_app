import 'package:fitlip_app/routes/App_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Utils/Colors.dart';
class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F'];
  final List<int> dates = [23, 24, 25, 26, 27, 28];
  int selectedDateIndex = 3; // Default to 26 (index 3 in our dates array)

  final List<String> categories = ['Shirts', 'Pants', 'Dressess', 'Shoes'];
  int selectedCategoryIndex = 2; // Default to Dressess

  // final List<OutfitItem> outfitItems = [
  //   OutfitItem(image: 'assets/Images/1.png'),
  //   OutfitItem(image: 'assets/Images/2.png'),
  //   OutfitItem(image: 'assets/Images/3.png'),
  //   OutfitItem(image: 'assets/Images/4.png'),
  //   OutfitItem(image: 'assets/Images/5.png'),
  //   OutfitItem(image: 'assets/Images/6.png'),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategoriesSection(),
              // const SizedBox(height: 16),
              // _buildCalendarRow(),
              const SizedBox(height: 24),
              _buildAvatarSection(),
              const SizedBox(height: 24),
              _buildOutfitSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(width: 16),
             Text(
              'Wardrobe',
              style: GoogleFonts.playfairDisplay(
                color: Color(0xFFAA8A00),
                fontSize: 24,
                fontWeight: FontWeight.bold,

              ),
            ),
          ],
        ),
        SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
Row(children: [
  GestureDetector(
    onTap: (){
      Navigator.pushNamed(context, AppRoutes.profile);
    },
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/Images/circle_image.png'),
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
  const SizedBox(width: 8),
  // Name
  const Text(
    'Johnny Cage',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  ),
],),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFAA8A00),
                  shape: BoxShape.circle
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.favorite_border,
                  color: Colors.black,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        // Profile image


        Expanded(
          flex: 3,
          child: Card(
            elevation: 4,
            child: Container(

              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(

              color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Filter button
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFAA8A00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.tune,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              categories.length,
                  (index) => _buildCategoryChip(categories[index], index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, int index) {
    final isSelected = index == selectedCategoryIndex;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategoryIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFAA8A00) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFAA8A00) : Colors.black54,
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  //
  // Widget _buildCalendarRow() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: List.generate(
  //       weekdays.length,
  //           (index) => _buildCalendarItem(weekdays[index], dates[index], index),
  //     ),
  //   );
  // }

  Widget _buildCalendarItem(String day, int date, int index) {
    final isSelected = index == selectedDateIndex;
    return InkWell(
      onTap: () {
        setState(() {
          selectedDateIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              color: isSelected ? const Color(0xFFAA8A00) : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // color: isSelected ?   : Colors.transparent,
              border: isSelected ? Border.all(color: const Color(0xFFAA8A00)) : null,
            ),
            child: Center(
              child: Text(
                date.toString(),
                style: TextStyle(
                  color: isSelected ? const Color(0xFFAA8A00) : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Avatar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/Images/main.png',
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildOutfitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Calendar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
    availableGestures: AvailableGestures.none,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: appcolor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: appcolor,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              showDialog(

                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title:  Text("No Outfit Set",style: GoogleFonts.poppins(color: appcolor,fontWeight: FontWeight.w600,fontSize: 21),),
                  content: const Text("You have not set outfit collection for today."),
                  actions: [
                    TextButton(
                      child:  Text("OK", style: TextStyle(color: appcolor)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  Widget _buildOutfitItem(OutfitItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset(
            item.image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFAA8A00)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Upload',
                style: TextStyle(
                  color: const Color(0xFFAA8A00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFAA8A00),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Save Outfit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for drawing dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 5;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Model for outfit items
class OutfitItem {
  final String image;
  bool isSelected;

  OutfitItem({
    required this.image,
    this.isSelected = false,
  });
}