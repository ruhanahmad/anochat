import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
// ···
 
  // ···
  

class CharityMatchesScreen extends StatelessWidget {
    Future<void> _authenticate() async {
  final localAuth = LocalAuthentication();

  try {
    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        bool isAuthenticated = await localAuth.authenticate(
          localizedReason: 'Authenticate to access the app', // Displayed to the user
        
          options: AuthenticationOptions(
              useErrorDialogs: true, // Show system dialogs (e.g., for Face ID)
          stickyAuth: true, // Keep the biometric prompt open until success or failure
          )
        );

        if (isAuthenticated) {
          // Authentication successful
          print('Authentication successful');
        } else {
          // Authentication failed
          print('Authentication failed');
        }
      } else {
        // Face ID is not available on this device
        print('Face ID is not available on this device');
      }
    } else {
      // Biometrics are not available on this device
      print('Biometrics are not available on this device');
    }
  } catch (e) {
    // Handle errors here
    print('Error: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Charity',
                style: TextStyle(
                  fontSize: 17.0,
                  // color: Colors.blue, // Text color in skublue
                
                ),
              ),
              SizedBox(width: 5,),
                  Text(
                'Matches',
                style: TextStyle(
                  fontSize: 17.0,
                  color: Color(0xFF7550E8), // Text color in skublue
             
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 350,
          padding: EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 photos in one row
              mainAxisSpacing: 8.0, // Adjust as needed
              crossAxisSpacing: 8.0, // Adjust as needed
            ),
            itemCount: 6, // Total number of photos
            itemBuilder: (context, index) {
              // Replace this with your image source
              String imageUrl = 'assets/$index.png';

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0), // Border radius of 30
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black, // Black shadow
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.grey, // Grey shadow
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black.withOpacity(0.7), // Dark background
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Your Text Here',
                            style: TextStyle(
                              color: Colors.white, // Text color
                             shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 55,
                                  offset: Offset(0, 20),
                                ),
                                Shadow(
                                  color: Colors.grey,
                                  blurRadius: 55,
                                  offset: Offset(0, 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
             Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
              GestureDetector(
                onTap: () {
                  _authenticate();
                },
                child: Text(
                  'Make a',
                  style: TextStyle(
                    fontSize: 17.0,
                    // color: Colors.blue, // Text color in skublue
                 
                  ),
                ),
              ),
              SizedBox(width: 5,),
                  Text(
                'donation',
                style: TextStyle(
                  fontSize: 17.0,
                  color: Color(0xFF7550E8), // Text color in skublue
                
                ),
              ),
              
                       ],
                     ),
                   ),



         Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Make a donation to someones',
                style: TextStyle(
                  fontSize: 17.0,
                  // color: Colors.blue, // Text color in skublue
                  
                ),
              ),
             
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                'favorite',
                style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.black,
                     // Text color in skublue
                  
                ),
              ),
               SizedBox(width: 5,),
                  Text(
                'chairty',
                style: TextStyle(
                      fontSize: 17.0,
                      color: Color(0xFF7550E8), // Text color in skublue
                     
                ),
              ),
                    ],
                  ),
         
                  ElevatedButton(
             onPressed: () {
               // Add your next button logic here
             },
             style: ElevatedButton.styleFrom(
               primary: Color(0xFF7550E8), // Light blue color
               shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
               ),
               padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 10.0), // Adjust padding as needed
             ),
             child: Text(
               'Next',
               style: TextStyle(
          color: Colors.white, // Text color
          fontSize: 18.0,
               ),
             ),
           )
              ,
         
                Text(
                'Skip',
                style: TextStyle(
                      fontSize: 17.0,
                      color: Color(0xFF7550E8), // Text color in skublue
                     
                ),
              ),
            ],
          ),
               ),
        // Other widgets below the GridView go here
      ],
    );
  }
}
