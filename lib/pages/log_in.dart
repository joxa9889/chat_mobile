import 'package:chat_project/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:chat_project/datas/data.dart';
import 'package:chat_project/pages/home_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {

  final TextEditingController _textEmailController = TextEditingController(); 
  final TextEditingController _textPasswordController = TextEditingController();
  String? error;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
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
                      'Welcome back you\'ve been missed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15
                      ),
                    ),
                
                    const SizedBox(
                      height: 25,
                    ),
                
                    SizedBox(
                      height: 68,
                      child: TextFormField(
                        validator: (value) {
                          if (error != null) {
                            return 'Not Valid Data';
                          }
                          return null;
                        },
                        controller: _textEmailController,
                        cursorColor: Colors.grey,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)
                          ),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          border: OutlineInputBorder()
                        ),
                      ),
                    ),
                
                    const SizedBox(
                      height: 10,
                    ),
                
                    SizedBox(
                      height: 68,
                      child: TextFormField(
                        validator: (value) {
                          if (error != null) {
                            return 'Not Valid Data';
                          }
                          return null;
                        },
                        obscureText: true,
                        controller: _textPasswordController,
                        cursorColor: Colors.grey,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600
                        ),
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)
                          ),
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.white
                          ),
                          border: OutlineInputBorder()
                        ),
                      ),
                    ),
                
                    const SizedBox(
                      height: 10,
                    ),
                
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Forget Password?',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                
                    const SizedBox(
                      height: 20,
                    ),
                
                    GestureDetector(
                      onTap: () async { 
                        var data = await Auth().makeAuth(_textEmailController.text, _textPasswordController.text);
                        if (data.containsKey('auth_token')) {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChattingContacts()));
                        } else {
                          setState(() {
                            print(data['non_field_errors'][0]);
                            error = data['non_field_errors'][0];
                            _formKey.currentState!.validate();
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(95, 0, 0, 0),
                          borderRadius: const BorderRadius.all(Radius.circular(10),),
                          border: Border.all(color: Colors.grey)
                        ),
                        width: double.infinity,
                        height: 68,
                        child: const Center(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.5,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        ),
                      ),
                    ),
                
                    const SizedBox(
                      height: 25,
                    ),
                
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                          ) 
                        ),
                
                        SizedBox(
                          width: 7,
                        ),
                        
                        Text(
                          'Or Continue with',
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                
                        SizedBox(
                          width: 7,
                        ),
                
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                          ) 
                        ),
                      ],
                    ),
                
                    const SizedBox(
                      height: 30,
                    ),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Image.asset('assets/Google_Icon.webp'),
                        ),
                
                        const SizedBox(
                          width: 30,
                        ),
                
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: 70,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: Image.asset('assets/apple_logo.png'),
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 30),
                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Registration()));
                          },
                          child: const Text(
                            ' Register Now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}