import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import fireStore
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseUser loggedInUser;
//firebase_storage
final _fireStore = Firestore.instance;
class ChatScreen extends StatefulWidget {
  static const String id = 'chat-screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;


  String messageText;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() async{
    try{
      //get current user
      final user = await _auth.currentUser();
      if(user != null){
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }catch(e){
      print("chat screen -> currentUser error:"+e);
    }
  }

  void messagesStream()async{
    // _fireStore.collection('collection').snapshots() => future objects
    await for( var snapshot in _fireStore.collection('messages').snapshots()){
      // snapshot -> list of message object
      for(var message in snapshot.documents){
        print(message.data);
      }
    }
  }

  getMessages()async{
    final messages = await _fireStore.collection('messages').getDocuments();
//    messages.documents -> whole document; message -> object
    for(var message in messages.documents){
      print( message.data);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality

               _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      // add data -> fireStore
                      _fireStore.collection('messages').add({
                        'text':messageText,
                        'sender': loggedInUser.email
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:_fireStore.collection('messages').snapshots(),
        // ignore: missing_return
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blueAccent,
                )
            );
          }
          // reverse -> always add new message at the end
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for(var message in messages){
            // fetch data from document text
            final messageText = message.data['text'];
            // fetch data from document sender
            final messageSender = message.data['sender'];
            // retrieve email -> current user
            final currentUser = loggedInUser.email;

            final messageBubble = MessageBubble(
                text:messageText,
                sender:messageSender,
                isMe: currentUser == messageSender,
            );
            // add to list
            messageBubbles.add(messageBubble);
          }
          // set list View -> scroll
          return Expanded(
            child: ListView(
              // make scroll stick at the end
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical:20),
              children:messageBubbles,
            ),
          );

        }
    );
  }
}



class MessageBubble extends StatelessWidget {
  MessageBubble({this.text, this.sender,this.isMe});
  final String text;
  final String sender;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(

            sender,
            style: TextStyle(
              fontSize: 12.0,
              color:Colors.black
            )
          ),
           Material(
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)
            ) : BorderRadius.only(
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)
            ),
            //drop down shadow
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Text('$text',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 15.0,
                  )
              ),
            ),
          ),

        ],

      ),
    );
  }
}

