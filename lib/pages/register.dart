import 'package:chat_project/datas/data.dart';
import 'package:chat_project/pages/home_page.dart';
import 'package:flutter/material.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordsMatch = true;

  bool isDigits(String str) {
    return int.tryParse(str) != null;
  }

  bool isAlpha(String str) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }

  TextEditingController username = TextEditingController();
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPasword = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
  var usernameError;


  Container input (placeholder, controller, inpType) => Container(
    margin: const EdgeInsets.symmetric(vertical: 5),
    child: TextFormField(
      validator: (value) {
        if (value!.trim().isNotEmpty) {
          if (inpType == 'name') {
            if (value.trim().length < 3) {
              return 'It should be at least 3 characters';
            }
          } else if (inpType == 'password') {
            if (value.length < 8) {
              return 'It should be at least 8 characters';
            } else if (isDigits(value)) {
              return 'It should as well as contain sybols';
            } else if (isAlpha(value)) {
              return 'It should contain at least one number';
            } else if (!isPasswordsMatch) {
              return 'Passwords didn\'t match';
            }
          } else if (inpType == 'username') {
            if (value.trim().length < 3) {
              return 'It should be at least 3 characters';
            } else if (value.contains(' ')) {
              return 'Your username shouldn\'t contain any spaces';
            } else if (usernameError != null) {
              return usernameError;
            }
          }
        } else {
          return 'Empty string not acceptable';
        }

        return null;
      },

      controller: controller,
      onChanged: (value) {
      },
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600
      ),
      decoration: InputDecoration(
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey)
        ),
        hintText: placeholder,
        hintStyle: const TextStyle(
          color: Colors.white
        ),
        border: const OutlineInputBorder()
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset('assets/liko.jpeg',)
                        ),
                      ),
                              
                      const SizedBox(
                        height: 15,
                      ),
                              
                      const Text(
                        'HELLO THERE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25
                        ),
                      ),
                              
                      const Text(
                        'Register below with your details!',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                              
                      const SizedBox(
                        height: 10,
                      ),
                              
                      input('Username', username, 'username'),
                              
                      Row(
                        children: [
                          Flexible(
                            child: input('First Name', firstName, 'name'),
                          ),
                              
                          const SizedBox(width: 10,),
                              
                          Flexible(
                            child: input('Last Name', lastName, 'name'),
                          ),
                        ],
                      ),
                              
                      input('Password', password, 'password'),
                              
                      input('Confirm Password', confirmPasword, 'password'),
                              
                      const SizedBox(
                        height: 20,
                      ),
                              
                      SizedBox(
                        width: double.infinity,
                        height: 68,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (password.text == confirmPasword.text) {
                              setState(() {
                                isPasswordsMatch = true;
                              });
                              if (_formKey.currentState!.validate()) {
                                var response = await Register().registerSMB(username.text, firstName.text, lastName.text, password.text);
                                if (response['username'] != username.text) {
                                  setState(() {
                                    usernameError = response['username'][0];
                                    _formKey.currentState!.validate();
                                  });
                                } else {
                                  usernameError = null;
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChattingContacts()));
                                }
                              }
                            } else {
                              setState(() {
                                isPasswordsMatch = false;
                                _formKey.currentState!.validate();
                              });
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(95, 0, 0, 0),),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.white)
                              )
                            )
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.5
                            ),
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}