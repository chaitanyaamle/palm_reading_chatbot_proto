
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palm_reading_chatbot_proto/loading.dart';
import 'package:palm_reading_chatbot_proto/models/chatbot.dart';
import 'package:palm_reading_chatbot_proto/slider_transition.dart';

import 'fake_scanner.dart';

void main() {
    runApp(const Chatbot());
}

class Chatbot extends StatelessWidget {
  const Chatbot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ChatbotContents());
  }
}

class ChatbotContents extends StatefulWidget {
  const ChatbotContents({Key? key}) : super(key: key);

  @override
  State<ChatbotContents> createState() => _ChatbotContentsState();
}

class _ChatbotContentsState extends State<ChatbotContents> with AutomaticKeepAliveClientMixin<ChatbotContents>{
  List<ChatbotModel> chatbotList = [];

  String command = "";
  String _category = "";
  int subCatIndex = 0;
  var sliderBool = true;
  String tempSubCatKey = "";
  String tempSubCatValue = "";
  File? imagePath;
  bool isLoading = false;

  int animationDelay = 0;

  bool animate = true;

  bool _wantKeepAlive = true;

  @override
  bool get wantKeepAlive => _wantKeepAlive;

  set myValue(bool value) {
    _wantKeepAlive = value;
  }

  final ScrollController _scrollController =  ScrollController();

  @override
  void initState() {
    initialiseChatBot();
    // print(chatbotList);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return isLoading ? const LoadingScreen() : NotificationListener(
      onNotification: (notificationInfo) {
        if (notificationInfo is ScrollStartNotification) {
          // print("scroll");
          // print("detail:${notificationInfo.dragDetails}");
          if(notificationInfo.dragDetails != null){
            _wantKeepAlive = false;
            animate = false;
          }
          else{
            animationDelay = 0;
            double maxScroll = _scrollController.position.maxScrollExtent;
            double currentScroll = _scrollController.position.pixels;
            if ( maxScroll+800 == currentScroll+800) {
              _wantKeepAlive = true;
            }
            animate = true;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 5, 39, 77),
          title: const Text("Palm Reading Chat-bot"),
          centerTitle: true,
          actions: [
            chatbotList.length >= 18 ? IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                  animationDelay = 0;
                  _wantKeepAlive = false;
                  initialiseChatBot();
                });
              },
            ) : const SizedBox()
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(6.0),
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("images/galaxy.jpg"), fit: BoxFit.fitHeight)),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: chatbotList.length,
            itemBuilder: (context, index) {
              final options = chatbotList[index].options;
              final subCatKeys = chatbotList[index].subCategoryKey;
              final subCatValues = chatbotList[index].subCategoryValues;
              if(subCatKeys != null && subCatValues != null){
                tempSubCatKey = subCatKeys.elementAt(subCatIndex);
                tempSubCatValue = subCatValues.elementAt(subCatIndex);
              }
              if(chatbotList[index].id != 1){
                animationDelay += 1400;
              }
              else{
                animationDelay = 0;
              }
              return Column(
                crossAxisAlignment: chatbotList[index].id != -1
                    ? chatbotList[index].id == 0
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end
                    : CrossAxisAlignment.center,
                children: [
                  chatbotList[index].toClick != true && chatbotList[index].subCatClick != true
                      ? chatbotList[index].showResult != true
                      ? chatbotList[index].id != 2 ? SlideFadeTransition(
                          userId: chatbotList[index].id == 1 ? 1 : 0,
                          direction: _wantKeepAlive ? Direction.horizontal : Direction.none,
                          delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                          child: displayData(chatbotList[index].text, index)
                      ) : SlideFadeTransition(
                              direction: _wantKeepAlive ? Direction.vertical : Direction.none,
                              delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                              child: showUserSubCatSlection(chatbotList[index].subCatKeyString! , chatbotList[index].subCatValueString!, index)
                      )
                      : SlideFadeTransition(
                              direction: _wantKeepAlive ? Direction.vertical : Direction.none,
                              delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                              child: displayResult(chatbotList[index].text)
                          )
                      : chatbotList[index].subCatClick != true ? options!.length > 2 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for(var data in options)
                            GestureDetector(
                                child: SlideFadeTransition(
                                    direction: _wantKeepAlive ? Direction.vertical : Direction.none,
                                    delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                                    child: displayData(data, index)
                                ),
                              onTap: () {
                                setState(() {
                                  command = data;
                                  addUserInput(command, index);
                                  print("COMMAND: $command");
                                  chatbotList.removeAt(index);
                                  updateChatBotList(command, index);
                                });
                              },
                            ),
                        ],
                      ) : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(var data in options)
                        GestureDetector(
                          child: SlideFadeTransition(
                              direction: _wantKeepAlive ? Direction.vertical : Direction.none,
                              delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                              child: displayData(data, index)
                          ),
                          onTap: () {
                            setState(() {
                              command = data;
                              addUserInput(command, index);
                              print("COMMAND: $command");
                              chatbotList.removeAt(index);
                              updateChatBotList(command, index);
                              // if(tempSubCatKey != "" && tempSubCatValue != ""){
                              //   if(command == "No, Re-Choose"){
                              //     chatbotList.removeAt(index-2);
                              //   }
                              //   // to remove slider from chatbot side
                              //   if(command == "Yes"){
                              //     if(sliderBool){
                              //       chatbotList.removeAt(index-2);
                              //       sliderBool = false;
                              //     }
                              //   }
                              // }
                            });
                          },
                        ),
                    ],
                  ) : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                               SlideFadeTransition(
                                  direction: _wantKeepAlive ? Direction.vertical : Direction.none,
                                  delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                                  child: displaySubCat(subCatKeys!, subCatValues!, index, subCatIndex)
                              ),
                          sliderBool ? SlideFadeTransition(
                            direction: _wantKeepAlive ? Direction.vertical : Direction.none,
                            delayStart: _wantKeepAlive ? Duration(milliseconds: animationDelay) : const Duration(milliseconds: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: const Color.fromARGB(255, 170, 203, 238),
                                  child: IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: () {
                                      setState(() {
                                        if(subCatIndex <= 0){
                                          subCatIndex = subCatKeys.length-1;
                                        }
                                        else{
                                          subCatIndex = subCatIndex - 1;
                                          print(subCatIndex);
                                        }
                                        tempSubCatKey = subCatKeys.elementAt(subCatIndex);
                                        tempSubCatValue = subCatValues.elementAt(subCatIndex);
                                      });
                                    },
                                  ),
                                ),
                                Card(
                                  color: const Color.fromARGB(255, 170, 203, 238),
                                  child: IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: () {
                                      setState(() {
                                        if(subCatIndex >=  subCatKeys.length-1){
                                          subCatIndex = 0;
                                        }
                                        else{
                                          subCatIndex = subCatIndex + 1;
                                          print(subCatIndex);
                                        }
                                        tempSubCatKey = subCatKeys.elementAt(subCatIndex);
                                        tempSubCatValue = subCatValues.elementAt(subCatIndex);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ) : const SizedBox()
                        ],
                      ),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget displaySubCat(Iterable<String> subCatKeys, Iterable<String> subCatValues, int index, int subCatIndex) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: chatbotList[index].id == 0
            ? const Color.fromARGB(255, 231, 180, 215)
            : const Color.fromARGB(255, 170, 203, 238),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: const DecorationImage(
                      image: AssetImage("images/gradient.jpg",),
                      fit: BoxFit.cover
                  )
              ),
              child: Image.asset(subCatKeys.elementAt(subCatIndex), height: 148, width: 130,),
            ),
            Container(
              constraints: const BoxConstraints(
                  minWidth: 15,
                  minHeight: 15,
                  maxWidth: 180,
                  maxHeight: 220
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(subCatValues.elementAt(subCatIndex), style: const TextStyle(fontSize: 18.0),),
            )
          ],
        ));
  }

  Widget displayData(data, index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: chatbotList[index].id == 0
            ? chatbotList[index].toClick != true && chatbotList[index].subCatClick != true
              ? const Color.fromARGB(255, 231, 180, 215) : const Color.fromARGB(255, 170, 203, 238)
            : const Color.fromARGB(255, 170, 203, 238),
        child: Column(
          children: [
            chatbotList[index].imageShow == true ? Container(
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: const DecorationImage(
                      image: AssetImage("images/gradient.jpg",),
                      fit: BoxFit.cover
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(chatbotList[index].imageText!, height: 190, width: 220,),
              ),
            ) : const SizedBox(),
            Container(
                margin: const EdgeInsets.all(12.0),
                constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                    maxWidth: 240,
                    maxHeight: 200
                ),
                child: Text(
                  data ?? "",
                  style: const TextStyle(fontSize: 18.0),
                )
            ),
          ],
        ));
  }

  Widget displayResult(data) {
    return Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color.fromARGB(255, 231, 180, 215), width: 4.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        child: Column(
          children: [
            Center(
              child: Container(
                  margin: const EdgeInsets.all(14.0),
                  padding: const EdgeInsets.all(12.0),
                  constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                      maxWidth: 300,
                      maxHeight: 500
                  ),
                  child: Text(
                    data ?? "",
                    style: const TextStyle(fontSize: 18.0),
                  )
              ),
            ),
          ],
        ));
  }

  List<String> optionAnswer(String text){
    Map<String, dynamic> optionOutput = {
      "Yes" : [
        "Health and Quality of life",
        "Love and Relationships",
        "Personality",
        "Marriage and Married life",
        "Career and Work-life",
        "Success",
        "Travelling and Adventures"
      ],
      "Choose Another Option" : [
        "Health and Quality of life",
        "Love and Relationships",
        "Personality",
        "Marriage and Married life",
        "Career and Work-life",
        "Success",
        "Travelling and Adventures"
      ],
      "Continue" : [
        "Health and Quality of life",
        "Love and Relationships",
        "Personality",
        "Marriage and Married life",
        "Career and Work-life",
        "Success",
        "Travelling and Adventures"
      ],
    };
    return optionOutput[text] ?? [];
  }

  String? getCategoryImage(String text){
    Map<String, String> category = {
      "Health and Quality of life": "images/life-line.png",
      "Love and Relationships": "images/heart-line.png",
      "Personality": "images/head-line.png",
      "Marriage and Married life": "images/marriage-line.png",
      "Career and Work-life": "images/fate-line.png",
      "Success": "images/success-line.png",
      "Travelling and Adventures": "images/travel-line.png",
    };
    return category[text];
  }

  List<String>? getFinalResult(String text){
    Map<String, dynamic> finalResult = {
      "Health and Quality of life": [
        "You have an inflexible nature. Your somewhat serious nature makes life difficult for you at times. At times, problems come later on in your life because you did not address them at first. A change in attitude will help you.",
        "You are not too clear about your ambition in life. You nearly always have an air of uncertainty about you. At times, you feel quite lethargic and bored. Try to change this habit of feeling lazy.",
        "You are a restless person. You love to travel and discover new places. You are unlikely to stay indoors. You are highly imaginative and creative. But you lose focus easily. If you can improve your concentration, you will be more successful.",
        "You are likely to lead a happy and healthy life. You are likely to be very passionate and romantic in life. You are kind and caring towards those around you. You are ambitious but try not to become complacent in whatever you do and you will achieve much."
      ], //Life Line
      "Love and Relationships": [
        "You are a die-hard lover. You take immense pride in the object of your affection. You will fail to spot any fault in your beloved. Love for you is beyond all reason. Because of your extremist nature in matters of affection, you are likely to face problems in your relationships."
        "You have a calmer nature when compared to others. But you think deeply in matters of romance. You do not like public display of affection. You can sacrifice everything for the one you care for. You maintain a fine balance between selflessness and selfishness in your relationships.",
        "You may be selfish in matters of love and romance. You are a reserved person and unlikely to indulge in public display of affection. If you like someone, you will try everything to woo that person. But once he/she is yours, your devotion towards your beloved goes down. If your partner commits a mistake, you find it very difficult to forgive.",
        "You are a very selfish lover. You live for yourself and care little for the people around you. When your partner commits a mistake, you can be very unforgiving. If you like someone, you stop at nothing to get that person in your life. But after winning your love, your devotion and attention level drops like a brick.",
        "You are a loyal lover. You have high morals and are unlikely to indulge in affairs. You will love once, but you will love for ever. You are most likely to have a normal and successful love life and unlikely to face a break-up. You believe in life-long relationships.",
        "You are very kind and affectionate. You are not very choosy about the person whom you want to be your partner. You have chances of meeting with great disappointment in your relationships or friendships. Your trust is likely to be broken by someone you love.",
        "You have a lucky love life. Your love life will be well-balanced, affectionate and happy. You will have great happiness in all matters of love and romance."
      ], //Heart Line
      "Personality": [
        "You are a very sensitive and timid person. You can get nervous or excited very easily. You have little control on your temper and hence you get into arguments and fights for the smallest of reasons. You also get hurt by people very easily.",
        "You have courage in voicing your opinion. You overcome your nervousness and are very determined in your work. If you are passionate for some cause, you fight till the end for it. You are a sensitive person. You approach new things with caution. Even though you may be capable, you lack self-confidence. You tend to undervalue your capabilities and talents.",
        "You tend to be indecisive. Your mind wavers between imagination and practicality. Instead of reasoning too much, you should rely on your intuition. You are a sensitive person. You approach new things with caution. Even though you may be capable, you lack self-confidence. You tend to undervalue your capabilities and talents.",
        "You have control over your imagination and use it whenever you wish. You are a sensitive person. You approach new things with caution. Even though you may be capable, you lack self-confidence. You tend to undervalue your capabilities and talents.",
        "You are controlled by your imagination. Your work is erratic and depends on your mood. You tend to do peculiar things. You are a sensitive person. You approach new things with caution. Even though you may be capable, you lack self-confidence. You tend to undervalue your capabilities and talents.",
        "You generally keep to yourself. Your extreme sensitiveness makes living life difficult for you. Most of the times, you feel gloomy. You are a sensitive person. You approach new things with caution. Even though you may be capable, you lack self-confidence. You tend to undervalue your capabilities and talents.",
        "You think independently. You have quick judgment and are mentally strong. Because of your fast thinking, you are brilliant in studies and whatever else you take up. Find your life goal and work towards it. Strong ambition will bring you success.",
        "You are born to be a leader of the masses. You can sacrifice everything for your public duties. You think independently. You have quick judgment and are mentally strong. Because of your fast thinking, you are brilliant in studies and whatever else you take up. Find your life goal and work towards it. Strong ambition will bring you success.",
        "Your work depends more on your mood. Even though you are clever, you may not achieve much if you depend on your mood. You think independently. You have quick judgment and are mentally strong. Because of your fast thinking, you are brilliant in studies and whatever else you take up. Find your life goal and work towards it. Strong ambition will bring you success.",
        "You have dual-mentality. You are capable of doing a large amount of mental work. At times you can be very sensitive and a cautious person. On the other hand, at times you feel very self-confident and have a desire to succeed with your views. You will have great wealth or great power at some point in your life."
      ], // Head Line
      "Marriage and Married life": [
        "You will have a happy marriage. There will be lots of love between you and your life partner.",
        "Your happily married life may end in a break-up after a few years of marriage.",
        "You will have a happy marriage. You will most likely outlive your life partner.",
        "You are not likely to marry.",
        "There will be stress and trouble in your married life. It will be because of the ill health of your partner.",
        "Your marriage will be delayed for a long time. The two of you will be living separately at the commencement of your married life.",
        "Some big trouble and separation could occur in the middle of your married life.",
        "Your marriage will most likely end in trouble and separation with your partner.",
        "You are advised not to marry since your marriages will be totally unhappy and lead to divorces.",
        "You and your life partner will stay away from each other after marriage.",
        "You and your life partner will stay away from each other and you may separate legally with a divorce.",
        "You will most likely marry someone with great wealth or with very high reputation and status."
      ], //Marriage Line
      "Career and Work-life": [
        "You will earn all the wealth you do through personal efforts.",
        "Your fate line indicates that you might earn money until the age of 55-58 years and that probably says that you might take up a government related field. It also indicates that you might have to face many failures in your love life but you will that find one person who would stay with you forever. You are also very fair at decision making and therefore people seek your advice.",
        "You are likely to make many wrong decisions which you won't realize until middle age. Try to fix the problems. Don't turn to desperate measures because that might worsen the matter. Talk to a close one and sort his help to work towards success. You are interested in challenging jobs which makes your life adventurous.",
        "You are likely to face tight conditions. You might end up doing jobs which you may not like and which might involve a lot of physical effort. There might be some monetary problems. However, don't ever give up and work hard.",
        "You are likely to meet someone who would help you in your business. That person would be beneficial to you and you would end up being best of friends and business partners. You might get a financial boost when this person enters your life and all problems might vanish automatically. There are going to be some problems interfering in your life, but with patience you can keep them at bay.",
        "You are most likely to gain support from your friends and family. They will support you in everything you do and be the reason behind your success. You are likely to have two forms of income- two businesses or an additional part time job. It also indicates that your spouse might be earning equally as you would and thus, your family won't ever face financial issues. Be confident in the ventures you take on and be patient.",
        "You are most likely to settle in a foreign country and earn very well there. You are creative and that widens your spectrum of opportunities. You are open to challenges and perfect in everything you do which makes you important for others. You are a perfect balance of practicality and emotions.",
        "You are a self made person. You are more likely to start earning since a very young age. You've made your passion into your career and that is the secret behind your success. Another reason behind your secret is the untiring support you receive from any one family member of yours. You are likely to pull out others from their misery.",
        "A broken fate line indicates that your life is full of uncertainty. Think twice before making any decisions."
      ], //Fate Line
      "Success": [
        "You are likely to be very successful. You are going to have a very good financial status and would start earning at an early age. Following your passion will make you unbeatable. You are informational and like to voice your opinions. You have set high standards for yourself and you are likely to achieve all your dreams. Stay grounded and help people who need help. It will help you grow more.",
        "You are inflexible and rigid and way too stubborn. This stands in between you and success. You have a negative outlook towards life which brings you more failure. If you want to achieve success take views of reliable people into consideration, work hard and stay grounded.",
        "Your stubborn behavior gets in the way every time you decide to try something new. You are poor at decision making skills and organizational skills. You are an introvert and you are not comfortable to work and adjust with others. Try to change your behavior if you want to be successful.",
        "This indicates that you are highly impractical and that you don't want to break from your bubble and try challenging things. You tend to be good follower than a leader and you are more likely to take up a job rather than starting your own business. Think practically if you want to achieve success.",
        "This indicates that you are very artistic. People love what you create and that helps you gain attention, wealth and respect. Everything is hard earned and you keep up with the reputation others have about you. You are grounded and help others to become better at life.",
        "You are a literary gem. You are excellent at writing and literature and likely to take it up as a career. You are excellent at communicating your emotions and thoughts to others. You understand others well and you are likely to help others deal with their emotions.",
        "You are hard working and very ambitious. You keep high hopes from yourself and see to that your achieve each of them. You don't let anything come in between success and you. You have fine literary skills and you are likely to make your passion your profession. You are likely to start your own publishing house. Anything you venture in can become a success, therefore think wise before making decisions.",
        "You are likely to be successful in later years of life. The most favorable fields for you are- business and engineering. Be honest in your work and you will see success sooner. With experience you will become wiser and that will help you make correct decisions regarding life."
      ], //Success Line
      "Travelling and Adventures": [
        "You are likely to leave your homeland and settle in foreign land for ever. Settling would be mostly for work purpose and not education, however your desire to gain more knowledge will take you to great places. Choose wisely where you want to settle down. You are a travel freak and tend to utilize all your money in traveling around the world. Travel where ever you want to so that you don’t have any wish unfulfilled later.",
        "You are more likely to go for small travels in near by countries or places. You are not a travel freak and would love to sit by the fireplace and drink coffee and read your favorite magazine.",
        "You are going to earn through your travel. The fact that you love traveling motivates you to work hard so that you can go overseas for work. All your voyages are going to be big and highly beneficial to you. Every trip you go on will change your life to a certain extent and make you a better person.",
        "You are likely to experience unsuccessful travels which you will definitely regret. Prevention is better than cure. Avoid traveling to farther off places, but that doesn’t mean you don’t travel at all. Cut down on unnecessary travels and travel only when needed.",
        "You are likely to suffer great losses from traveling. Going on unnecessary trips would be costly and unlucky for you. Rather than going on long travels to far places, go on short trips within your country. Be careful of your belongings, finances and health while your are traveling."
      ], //Travel Line
    };
    return finalResult[text];
  }

  String? getCatLine(String text){
    Map<String, String> categoryLine = {
      "Health and Quality of life": "Life Line",
      "Love and Relationships": "Heart Line",
      "Personality": "Head Line",
      "Marriage and Married life": "Marriage Line",
      "Career and Work-life": "Fate Line",
      "Success": "Success Line",
      "Travelling and Adventures": "Travel Line",
    };
    return categoryLine[text];
  }

  Map<String,String> getSubCategory(String text){
    Map<String, dynamic> subCatOutput = {
      "Health and Quality of life" : {
        "images/subCat/lifeLine/life1.png" : "Straight Life Line",
        "images/subCat/lifeLine/life2.png" : "Short Life Line",
        "images/subCat/lifeLine/life3.png" : "Life Line crossing the palm",
        "images/subCat/lifeLine/life4.png" : "Rounded Life Line",
        },
      "Love and Relationships" : {
        "images/subCat/heartLine/heart1.png" : "Heart line begins just outside the base of the index finger.",
        "images/subCat/heartLine/heart2.png" : "Heart line begins between the index and middle finger.",
        "images/subCat/heartLine/heart3.png" : "Heart line begins just below the middle finger.",
        "images/subCat/heartLine/heart4.png" : "Heart line begins a bit below the base of the middle finger.",
        "images/subCat/heartLine/heart5.png" : "Heart line begins below the index finger.",
        "images/subCat/heartLine/heart6.png" : "Heart line curves downward near the base of the index finger.",
        "images/subCat/heartLine/heart7.png" : "Heart line commences with a fork, one branch below the index finger and the other between the index and middle fingers.",
      },
      "Personality" : {
        "images/subCat/headLine/head1.png" : "Head line begins from inside the life line.",
        "images/subCat/headLine/head2.png" : "Head line is joined to the life line and runs straight across the palm.",
        "images/subCat/headLine/head3.png" : "Head line is joined to the life line and is forked.",
        "images/subCat/headLine/head4.png" : "Head line is joined to the life line and gently bends downwards.",
        "images/subCat/headLine/head5.png" : "Head line is joined to the life line and bends too far downwards.",
        "images/subCat/headLine/head6.png" : "Head line is joined to the life line, bends down and then turns with a curve.",
        "images/subCat/headLine/head7.png" : "Head line is separated and above the life line.",
        "images/subCat/headLine/head8.png" : "Head line is separated and above the life line and the head line curves slightly upwards.",
        "images/subCat/headLine/head9.png" : "Head line is separated and above the life line and the head line curves slightly downwards.",
        "images/subCat/headLine/head10.png" : "Double Head Line",
      },
      "Marriage and Married life" : {
        "images/subCat/marriageLine/marriage1.png" : "Line is straight and clear without any breaks",
        "images/subCat/marriageLine/marriage2.png" : "Line is straight and clear with a break in between",
        "images/subCat/marriageLine/marriage3.png" : "Line curves downwards",
        "images/subCat/marriageLine/marriage4.png" : "Line curves upwards",
        "images/subCat/marriageLine/marriage5.png" : "Clear line with lots of little lines dropping from it",
        "images/subCat/marriageLine/marriage6.png" : "There is an island at the beginning of the line",
        "images/subCat/marriageLine/marriage7.png" : "There is an island in the middle of the line",
        "images/subCat/marriageLine/marriage8.png" : "There is an island at the end of the line",
        "images/subCat/marriageLine/marriage9.png" : "There are many islands in the line (like a chain)",
        "images/subCat/marriageLine/marriage10.png" : "The line is forked",
        "images/subCat/marriageLine/marriage11.png" : "The line is forked and turns downwards towards the heart line",
        "images/subCat/marriageLine/marriage12.png" : "The line goes into the hand and joins upward with the line of Sun",
      },
      "Career and Work-life" : {
        "images/subCat/fateLine/fate1.png" : "Fate Line begins at the middle of the wrist and ends at the mount of Saturn",
        "images/subCat/fateLine/fate2.png" : "Fate Line ends at the Heart Line",
        "images/subCat/fateLine/fate3.png" : "Fate Line goes towards the Head Line",
        "images/subCat/fateLine/fate4.png" : "No Fate Line",
        "images/subCat/fateLine/fate5.png" : "Fate line with branches",
        "images/subCat/fateLine/fate6.png" : "Fate line is accompanied by another parallel line",
        "images/subCat/fateLine/fate7.png" : "Fate line beginning from the Mount of Moon",
        "images/subCat/fateLine/fate8.png" : "Fate line beginning from the Life Line",
        "images/subCat/fateLine/fate9.png" : "Broken Fate Line",
      },
      "Success" : {
        "images/subCat/successLine/success1.png" : "Success Line is straight, long and deep",
        "images/subCat/successLine/success2.png" : "Success Line is curved",
        "images/subCat/successLine/success3.png" : "Success Line is broken",
        "images/subCat/successLine/success4.png" : "Success Line is cut by a straight line",
        "images/subCat/successLine/success5.png" : "Success Line starts from the Mount of Venus",
        "images/subCat/successLine/success6.png" : "Success Line starts from the Mount of Moon",
        "images/subCat/successLine/success7.png" : "Success Line starts from the Life Line",
        "images/subCat/successLine/success8.png" : "Success Line starts from the Heart Line",
      },
      "Travelling and Adventures" : {
        "images/subCat/travelLine/travel1.png" : "Travel line ends like a fork and one branch goes to the Mount of Lower Moon and other to the mount of Venus",
        "images/subCat/travelLine/travel2.png" : "Travel Line starts from the Mount of Lower moon and goes towards the Life Line",
        "images/subCat/travelLine/travel3.png" : "Travel line starts from the Mount of Lower moon and ends at the Fate, Sun or Life Line",
        "images/subCat/travelLine/travel4.png" : "Travel line comes from the Mount of Lower Moon and goes downwards towards the wrist",
        "images/subCat/travelLine/travel5.png" : "Travel Line has an island at the end",
      },
    };
    return subCatOutput[text] ?? {};
  }

  void updateChatBotList(String text, int index) {
    setState(() {
      if(text == "Yes"){
        if(tempSubCatKey != "" && tempSubCatValue != ""){
          if(!sliderBool){
            chatbotList.add(ChatbotModel.addItem(0, "Opens scanner and scan your hand"));
            chatbotList.add(ChatbotModel.options(0, ["Open Camera"], true));
            scrollToAnimate();
          }
          else{
            chatbotList.add(ChatbotModel.userSubCategory(2, tempSubCatKey, tempSubCatValue, false));
            String? catLine = getCatLine(_category);
            chatbotList.add(ChatbotModel.addItem(0, "Is your $catLine made of small chains in between?"));
            chatbotList.add(ChatbotModel.options(0, ["Yes", "No"], true));
            chatbotList.removeAt(index-2);
            sliderBool = false;
            scrollToAnimate();
          }
        }
        else {
          List<String> category = optionAnswer(text);
          print(category);
          chatbotList.add(ChatbotModel.addItem(0, "What would you like to know about?"));
          chatbotList.add(ChatbotModel.options(0, category, true));
          scrollToAnimate();
        }
      }
      if(text == "No"){
        imagePath = null;
        print("IMAGE PATH: $imagePath");
        if(tempSubCatKey != "" && tempSubCatValue != ""){
          if(imagePath == null){
            chatbotList.add(ChatbotModel.addItem(0, "Opens scanner and scan your hand"));
            chatbotList.add(ChatbotModel.options(0, ["Open Camera"], true));
          }
          else{
            chatbotList.add(ChatbotModel.addItem(0, "Thank you have a nice day!"));
          }
        }
        else{
          chatbotList.add(ChatbotModel.addItem(0, "Thank you have a nice day!"));
        }
        scrollToAnimate();
      }
      if(text == "Stop"){
        chatbotList.add(ChatbotModel.addItem(0, "Thank you have a nice day!"));
        scrollToAnimate();
      }
      if(text == "Health and Quality of life" || text == "Love and Relationships" ||
          text == "Personality" || text == "Marriage and Married life" ||
          text == "Career and Work-life" || text == "Success" ||
          text == "Travelling and Adventures"){
        setState(() {
          _category = text;
          print(_category);
        });
        String? category = getCategoryImage(text);
        String? catLine = getCatLine(text);
        print("$text >>> $category");
        chatbotList.add(ChatbotModel.addItem(0, "In the realm of palm reading your $text is defined by the $catLine", true, category));
        chatbotList.add(ChatbotModel.addItem(0, "Find out more about your $text by analyzing your palm "));
        chatbotList.add(ChatbotModel.options(0, ["Continue", "Choose Another Option"], true));
        scrollToAnimate();
      }
      if(text == "Choose Another Option"){
        List<String> category = optionAnswer(text);
        print(category);
        chatbotList.add(ChatbotModel.addItem(0, "What would you like to know about?"));
        chatbotList.add(ChatbotModel.options(0, category, true));
        scrollToAnimate();
      }
      if(text == "Continue"){
        if(_category != ""){
          Map<String, String> category = getSubCategory(_category);
          print(category.values);
          chatbotList.add(ChatbotModel.addItem(0, "What does your palm look like?"));
          chatbotList.add(ChatbotModel.subCategory(0, category.keys, category.values, true));
          chatbotList.add(ChatbotModel.addItem(0, "Choose this option?"));
          chatbotList.add(ChatbotModel.options(0, ["Yes","No, Re-Choose"], true));
          print("CATEGORY: $_category");
        }
        else{
          List<String> category = optionAnswer(text);
          print(category);
          chatbotList.add(ChatbotModel.addItem(0, "What would you like to know about?"));
          chatbotList.add(ChatbotModel.options(0, category, true));
        }
        scrollToAnimate();
      }
      if(text == "No, Re-Choose"){
        Map<String, String> category = getSubCategory(_category);
        print(category.values);
        chatbotList.add(ChatbotModel.addItem(0, "What does your palm look like?"));
        chatbotList.add(ChatbotModel.subCategory(0, category.keys, category.values, true));
        chatbotList.add(ChatbotModel.addItem(0, "Choose this option?"));
        chatbotList.add(ChatbotModel.options(0, ["Yes","No, Re-Choose"], true));
        chatbotList.removeAt(index-2);
        print("CATEGORY: $_category");
        scrollToAnimate();
      }
      if(text == "Restart"){
        initialiseChatBot();
        setState(() {
          initialiseChatBot();
          _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut);
        });
      }
      if(text == "Open Camera"){
        _awaitReturnValue();
        List<String>? finalResult = getFinalResult(_category);
        print(finalResult![subCatIndex]);
        String result = finalResult[subCatIndex];
        chatbotList.add(ChatbotModel.addItem(0, "Your result is ready."));
        chatbotList.add(ChatbotModel.addItem(0, "Your $_category Analysis."));
        chatbotList.add(ChatbotModel.addResut(-1, result, true));
        initValues();
        chatbotList.add(ChatbotModel.addItem(0, "Would you like to know about something else?"));
        chatbotList.add(ChatbotModel.options(0, ["Continue","Stop"], true));
        scrollToAnimate();
      }
    });
  }

  void addUserInput(String text, int index) {
    setState(() {
      chatbotList.add(ChatbotModel.addItem(1, text));
      print(chatbotList);
      animationDelay = 0;
    });
  }

  void initialiseChatBot() {
    initValues();
    chatbotList = [];
    chatbotList.add(ChatbotModel.addItem(0, "Hey"));
    chatbotList.add(ChatbotModel.addItem(0, "Welcome to Palm Reading"));
    chatbotList.add(ChatbotModel.addItem(0, "Get an insight into what the future beholds for you!"));
    chatbotList.add(ChatbotModel.addItem(0, "Are you ready to delve into your palm lines and reveal your secrets?"));
    chatbotList.add(ChatbotModel.options(0, ["Yes", "No"], true));
    print("ANIMATE: $animate");
  }

  void scrollToAnimate() {
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent+800,
        duration: const Duration(milliseconds: 2000),
        curve: Curves.easeInOut);
  }

  void _awaitReturnValue() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (builder) => const Scanner()));
    setState(() {
      imagePath = result;
    });
  }

  void initValues() {
    command = "";
    _category = "";
    tempSubCatKey = "";
    tempSubCatValue = "";
    subCatIndex = 0;
    sliderBool = true;
    imagePath = null;
    print("Command: $command");
    print("Category: $_category");
    print("subCatIndex: $subCatIndex");
    print("tempKey: $tempSubCatKey");
    print("tempValue: $tempSubCatValue");
    print("ImagePath: $imagePath");
  }

  //display selection of Sub category at user side and remove the sliderBool Widget from list.
  Widget showUserSubCatSlection(String subCatKeyString, String subCatValueString, int index) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: const Color.fromARGB(255, 231, 180, 215),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  image: const DecorationImage(
                      image: AssetImage("images/gradient.jpg",),
                      fit: BoxFit.cover
                  )
              ),
              child: Image.asset(subCatKeyString, height: 148, width: 130,),
            ),
            Container(
              constraints: const BoxConstraints(
                minWidth: 15,
                minHeight: 15,
                maxWidth: 160,
                maxHeight: 200,
              ),
              padding: const EdgeInsets.all(12.0),
              child: Text(subCatValueString, style: const TextStyle(fontSize: 18.0),),
            )
          ],
        ));
  }
}