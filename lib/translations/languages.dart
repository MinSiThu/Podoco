import 'package:get/get.dart';

class Languages extends Translations{
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US':{
      "about":"""Podoco app is about classifying diseases in Cassava plant. 

                We made this project to showcase the use of tflite in Flutter. We use CropNet Lite Model. 
                The lite version may not be accurate because of the mobile phone computational performance today.
                
                The app source code is opensource and can be used freely according to MIT Lisence.
                The following link is the link to the opensource repo.
                """
    },
    'my_MM':{
      "about":"""Podoco အက်ပလီကေးရှင်းသည် ပီလောပီနံပင်ရှိ ရောဂါများကို အမျိုးအစားခွဲခြင်းအကြောင်းဖြစ်သည်။
                Flutter တွင် tflite အသုံးပြုမှုကို ပြသရန် ဤပရောဂျက်ကို ပြုလုပ်ခဲ့သည်။ ကျွန်ုပ်တို့သည် CropNet Lite မော်ဒယ်ကို အသုံးပြုသည်။
                ယနေ့ခေတ် မိုဘိုင်းလ်ဖုန်း၏ ကွန်ပျူတာဆိုင်ရာ စွမ်းဆောင်ရည်ကြောင့် Lite ဗားရှင်းသည် တိကျမှု မရှိနိုင်ပါ။
                
                အက်ပ်အရင်းအမြစ်ကုဒ်သည် opensource ဖြစ်ပြီး MIT Lisence အရ လွတ်လပ်စွာ အသုံးပြုနိုင်သည်။
                အောက်ပါလင့်ခ်သည် opensource repo သို့ လင့်ခ်ဖြစ်သည်။"""
    }
  }
  ;
}