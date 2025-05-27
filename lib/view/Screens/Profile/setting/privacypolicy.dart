import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFAA8A00),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFAA8A00)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
                'This Privacy Policy describes Our policies and procedures on the collection, use and disclosure '
                'of Your information when You use the Service and tells You about Your privacy rights and how '
                'the law protects You.\n\n'
                'We use Your Personal data to provide and improve the Service. By using the Service, You agree '
                'to the collection and use of information in accordance with this Privacy Policy.'),
            _buildSectionTitle('2. Interpretation and Definitions'),
            _buildSectionSubtitle('Interpretation'),
            _buildSectionContent(
                'The words of which the initial letter is capitalized have meanings defined under the following '
                'conditions. The following definitions shall have the same meaning regardless of whether they '
                'appear in singular or in plural.'),
            _buildSectionSubtitle('Definitions'),
            _buildDefinitionItem('Account',
                'means a unique account created for You to access our Service or parts of our Service.'),
            _buildDefinitionItem('Affiliate',
                'means an entity that controls, is controlled by or is under common control with a party.'),
            _buildDefinitionItem('Application',
                'refers to fitlit, the software program provided by the Company.'),
            _buildDefinitionItem('Company',
                '(referred to as either "the Company", "We", "Us" or "Our" in this Agreement) refers to fitlit.'),
            _buildDefinitionItem(
                'Country', 'refers to: California, United States'),
            _buildDefinitionItem('Device',
                'means any device that can access the Service such as a computer, a cellphone or a digital tablet.'),
            _buildSectionTitle('3. Collecting and Using Your Personal Data'),
            _buildSectionSubtitle('Types of Data Collected'),
            _buildSectionSubtitle('Personal Data'),
            _buildSectionContent(
                'While using Our Service, We may ask You to provide Us with certain personally identifiable '
                'information that can be used to contact or identify You. Personally identifiable information '
                'may include, but is not limited to:\n\n'
                '- Email address\n'
                '- First name and last name\n'
                '- Phone number\n'
                '- Address, State, Province, ZIP/Postal code, City\n'
                '- Usage Data'),
            _buildSectionSubtitle('Usage Data'),
            _buildSectionContent(
                'Usage Data is collected automatically when using the Service.\n\n'
                'Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), '
                'browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, '
                'the time spent on those pages, unique device identifiers and other diagnostic data.'),
            _buildSectionTitle('4. Use of Your Personal Data'),
            _buildSectionContent(
                'The Company may use Personal Data for the following purposes:\n\n'
                '- To provide and maintain our Service\n'
                '- To manage Your Account\n'
                '- For the performance of a contract\n'
                '- To contact You\n'
                '- To provide You with news, special offers and general information\n'
                '- To manage Your requests\n'
                '- For business transfers\n'
                '- For other purposes'),
            _buildSectionTitle('5. Retention of Your Personal Data'),
            _buildSectionContent(
                'The Company will retain Your Personal Data only for as long as is necessary for the purposes '
                'set out in this Privacy Policy. We will retain and use Your Personal Data to the extent '
                'necessary to comply with our legal obligations, resolve disputes, and enforce our legal '
                'agreements and policies.'),
            _buildSectionTitle('6. Security of Your Personal Data'),
            _buildSectionContent(
                'The security of Your Personal Data is important to Us, but remember that no method of '
                'transmission over the Internet, or method of electronic storage is 100% secure. While We '
                'strive to use commercially acceptable means to protect Your Personal Data, We cannot '
                'guarantee its absolute security.'),
            _buildSectionTitle('7. Children\'s Privacy'),
            _buildSectionContent(
                'Our Service does not address anyone under the age of 13. We do not knowingly collect '
                'personally identifiable information from anyone under the age of 13. If You are a parent '
                'or guardian and You are aware that Your child has provided Us with Personal Data, please '
                'contact Us.'),
            _buildSectionTitle('8. Changes to this Privacy Policy'),
            _buildSectionContent(
                'We may update Our Privacy Policy from time to time. We will notify You of any changes by '
                'posting the new Privacy Policy on this page.\n\n'
                'You are advised to review this Privacy Policy periodically for any changes. Changes to this '
                'Privacy Policy are effective when they are posted on this page.'),
            _buildSectionTitle('9. Contact Us'),
            _buildSectionContent(
                'If you have any questions about this Privacy Policy, You can contact us:\n\n'
                'By email: daniyalqamar1007@gmail.com'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFAA8A00),
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        content,
        style: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildDefinitionItem(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: '$term ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: definition),
          ],
        ),
      ),
    );
  }
}
