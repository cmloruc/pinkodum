/// Mock analiz metinleri — her hane (1-9) için kişilik yorumları.
/// İleride AI API çağrısı ile değiştirilecek; sabit veri fallback olarak kalır.
class MockAnalysisData {
  MockAnalysisData._();

  // ─── Kişilik Özeti — tam versiyon (premium) ─────────────────────────────────
  static String personalitySummary(String name, int h1, int h4, int h9) {
    final variants = _personalityVariants[h1] ?? _personalityVariants[1]!;
    final base = variants[h9 % variants.length];
    final depth = _depthByDigit[h4] ?? _depthByDigit[1]!;
    return '$name, $base\n\n$depth';
  }

  // ─── Kişilik Özeti — teaser versiyon (ücretsiz, merak uyandıran 2 cümle) ────
  static String personalitySummaryTeaser(String name, int h1, int h9) {
    final teasers = _personalityTeasers[h1] ?? _personalityTeasers[1]!;
    return '$name, ${teasers[h9 % teasers.length]}';
  }

  static const Map<int, List<String>> _personalityTeasers = {
    1: [
      'sen bir odaya girdiğinde fark yaratıyorsun — bunu kasıtlı yapmıyorsun, sadece oluyorsun. Pin kodun, bu enerjinin neden bu kadar güçlü olduğunu açıklıyor.',
      'içinde sürekli yanan bir ateş var. Pin kodun, bu ateşin neyi yakıtladığını ve nerede seni yorduğunu gösteriyor.',
      'liderlik sende öğrenilmiş bir beceri değil — içinden gelen bir çağrı. Detaylı analizde bu enerjinin tüm boyutlarını görebilirsin.',
    ],
    2: [
      'dışarıdan sakin görünürsün ama iç dünyan çok daha derin. Pin kodun, bu derinliğin hangi alanlarda gücüne dönüştüğünü gösteriyor.',
      'insanları kelimesiz anlıyorsun — bu sıradan bir yetenek değil. Detaylı analizde bu sezginin kaynağını keşfedebilirsin.',
      'sen köprü kuran birisin. Pin kodun, hangi ilişkilerde bu gücünün en çok parladığını ortaya koyuyor.',
    ],
    3: [
      'seninle aynı odada olmak insanlara iyi hissettiriyor. Pin kodun, bu enerjinin nereden geldiğini ve nasıl kullanabileceğini gösteriyor.',
      'yaratıcılığın sıradan değil — ama tam olarak nereye akıyor? Detaylı analizde bunu görebilirsin.',
      'sözcüklerle, fikirlerle büyü yapıyorsun. Pin kodun bu gücün hangi boyutlarda olduğunu açıklıyor.',
    ],
    4: [
      'güvenilir olmak senin için doğal — ama bunun bir bedeli var. Detaylı analizde bu dengeyi görebilirsin.',
      'her şeyde sağlam temeller kuruyorsun. Pin kodun, bu özelliğin sana ne kazandırdığını ve nerede sınırladığını gösteriyor.',
      'sabır senin en büyük silahın. Detaylı analizde bu silahı nasıl daha iyi kullanacağını keşfedebilirsin.',
    ],
    5: [
      'özgürlük senin için bir ihtiyaç — ama neden bu kadar güçlü? Pin kodun bunu açıklıyor.',
      'değişim seni köreltmez, keskinleştirir. Detaylı analizde bu enerjinin tam potansiyelini görebilirsin.',
      'her yeni kapı sana yeni bir sen sunuyor. Pin kodun bu yolculuğun haritasını çiziyor.',
    ],
    6: [
      'sevdiklerini korumak senin için en doğal şey — ama bu seni zaman zaman yoruyor. Detaylı analizde bu dengeyi görebilirsin.',
      'empatin güçlü ama bazen sınırın nerede olduğunu bulmak zor. Pin kodun bu noktaları gösteriyor.',
      'bir sığınak yaratıyorsun insanlar için. Detaylı analizde bu enerjinin tüm boyutlarını keşfedebilirsin.',
    ],
    7: [
      'yüzeyin altındaki gerçeği görmek senin için bir tutku. Pin kodun bu merakın seni nereye götürdüğünü açıklıyor.',
      'soru sormak seni besliyor — ama bazen cevap beklerken hayat geçiyor. Detaylı analizde bu dinamiği görebilirsin.',
      'içinde inanılmaz bir bilgelik var. Detaylı analizde bunu nasıl daha fazla kullanabileceğini keşfedebilirsin.',
    ],
    8: [
      'büyük hedefler koyuyorsun ve azimle ilerliyorsun. Pin kodun bu gücün tam olarak nerede çalıştığını gösteriyor.',
      'başarıya olan açlığın seni çok ileriye götürüyor — ama bir bedeli var. Detaylı analizde bunu görebilirsin.',
      'güçlü birisin ama bu güç tam olarak nereden geliyor? Pin kodun cevabı burada.',
    ],
    9: [
      'insanlığa olan bağın seni özel kılıyor. Pin kodun, bu bağın neden bu kadar derin olduğunu gösteriyor.',
      'büyük resmi görüyorsun ama bazen en yakındakileri kaçırıyorsun. Detaylı analizde bu dengeyi görebilirsin.',
      'şefkatin evrensel — ama kendin için de yeterince var mı? Pin kodun bu soruyu cevaplıyor.',
    ],
  };

  // ─── Güçlü Yön — teaser (1 cümle) ──────────────────────────────────────────
  static String strengthTeaser(String name, int h5) {
    final s = _strengthTeasers[h5] ?? _strengthTeasers[1]!;
    return '$name, $s';
  }

  static const Map<int, String> _strengthTeasers = {
    1: 'en büyük gücün harekete geçme cesareti — ama tam potansiyelini görmek için detaylı analiz gerekiyor.',
    2: 'insanları anlama yeteneğin sıradan değil — detaylı analizde ne kadar güçlü olduğunu keşfedebilirsin.',
    3: 'yaratıcılığın ve iletişim gücün büyük bir avantaj — detaylı analizde bunu nasıl kullanacağını görebilirsin.',
    4: 'güvenilirliğin paha biçilmez — detaylı analizde bu gücün hangi alanlarda en çok parladığını öğrenebilirsin.',
    5: 'değişime uyum sağlama yeteneğin istisna — detaylı analizde bu gücün tüm boyutlarını keşfedebilirsin.',
    6: 'şefkatin ve empatini gerçek bir güç — detaylı analizde bunu nasıl koruyacağını da görebilirsin.',
    7: 'derinlemesine düşünme kapasiten çok değerli — detaylı analizde bu gücün tam potansiyelini görüyorsun.',
    8: 'kararlılığın ve vizyonun güçlü — detaylı analizde bu enerjinin nereye götürdüğünü keşfedebilirsin.',
    9: 'şefkat ve vizyon bir arada nadir — detaylı analizde bu kombinasyonun gücünü görebilirsin.',
  };

  // ─── Dikkat Alanı — teaser (1 cümle, merak uyandıran) ───────────────────────
  static String warningTeaser(String name, int h6) {
    final w = _warningTeasers[h6] ?? _warningTeasers[1]!;
    return '$name, $w';
  }

  static const Map<int, String> _warningTeasers = {
    1: 'pin kodunda seni yavaşlatan gizli bir kalıp var — detaylı analizde bunu görebilirsin.',
    2: 'başkalarına o kadar çok veriyorsun ki kendi bardağın ne zaman boşalıyor? Detaylı analizde bu noktayı keşfedebilirsin.',
    3: 'harika fikirler var ama bir noktada takılıyorsun — detaylı analizde nerede ve neden olduğunu görebilirsin.',
    4: 'kontrolü bırakmak en zor şey — detaylı analizde bu kalıbın seni nasıl etkilediğini görebilirsin.',
    5: 'özgürlük ihtiyacın bazen bir şeylere mal oluyor — detaylı analizde bu dengeyi keşfedebilirsin.',
    6: '"hayır" demek neden bu kadar zor? Detaylı analizde pin kodundaki bu kalıbı görebilirsin.',
    7: 'düşünürken bazen hayat geçiyor — detaylı analizde bu kalıbın kaynağını keşfedebilirsin.',
    8: 'başarı odağın değerli ama bir bedeli var — detaylı analizde bunu tam olarak görebilirsin.',
    9: 'herkese verirken kendin için ne kalıyor? Detaylı analizde pin kodundaki bu dinamiği görebilirsin.',
  };

  static const Map<int, List<String>> _personalityVariants = {
    1: [
      'sen doğanın sana verdiği güçlü bir liderlik enerjisi taşıyorsun. '
          'Yolunu çizmekte kararlısın ve bu kararlılık zaman zaman seni çevrenden soyutlasa da, '
          'aslında başkalarına ilham vermenin tam da senin doğanda olduğunu herkes hissediyor. '
          'Bir hedef koyduğunda arkana bakmadan ilerliyorsun; bu özelliğin hem en büyük gücün hem de zaman zaman gözden kaçırdıkların oluyor. '
          'İçinde sürekli yanan bir "daha iyisini yapabilirim" ateşi var — bu seni diri tutuyor.',

      'sen bir odaya girdiğinde havayı değiştiren birisin. '
          'İnsanlar seni fark ediyor; sadece ne söylediğin için değil, nasıl durduğun için. '
          'Harekete geçmek senin için düşünmekten daha kolay — bu yüzden bazen planlamadan önce koştuğunu fark ediyorsun. '
          'Bağımsızlık senin için bir lüks değil, temel bir ihtiyaç. '
          'Kendi kararlarını kendin vermek, senin için özgürlüğün ta kendisi.',

      'liderlik sende sonradan öğrenilmiş bir beceri değil, içinden gelen bir çağrı. '
          'Karmaşık durumlarda bile net düşünebiliyorsun ve bu netlik çevrendekiler için bir çıpa oluyor. '
          'Başarıya olan açlığın seni ilerletiyor ama zaman zaman bu açlığın seni dinlendirmediğini de fark ediyorsun. '
          'Yanlış yapmaktan değil, hareketsiz kalmaktan korkuyorsun — ve bu korku seni çoğu zaman doğru yere götürüyor.',
    ],

    2: [
      'sen dışarıdan sakin ve uyumlu görünsen de, iç dünyanda oldukça derin hisseden birisin. '
          'İnsanların enerjisini çabuk alıyorsun ve bazen bunun seni yorduğunu fark ediyorsun. '
          'Empatin o kadar güçlü ki, bazen başkasının acısını ya da sevincini kendi içinde yaşıyorsun. '
          'Sessiz ama güçlü birisin — söylemeden çok hissettirerek etki yaratıyorsun. '
          'İlişkiler senin için her şeyin merkezinde; bağ kurmak, anlaşılmak ve anlamak seni besleyen şeyler.',

      'sezgilerine güvenmek sana doğal geliyor ama bazen bu iç sesin doğru söylediğini kabul etmek için dışarıdan onay arıyorsun. '
          'Halbuki o iç ses çoğunlukla haklı. '
          'İnsanları anlama yeteneğin seni hem çok değerli hem de zaman zaman yorgun bırakıyor. '
          'Ortamlarda en ince titreşimleri bile alıyorsun — bu bir hediye ama aynı zamanda bir yük. '
          'Bazen tek ihtiyacın sessizlik ve kendi enerjinle yalnız kalmak.',

      'sen köprü kuran birisin — iki taraf arasında, iki bakış arasında, iki insan arasında. '
          'Bu arabuluculuk yeteneği senin doğana o kadar işlemiş ki çoğu zaman farkında bile olmadan yapıyorsun. '
          'İçinde sürekli bir denge arayışı var; hem kendin olmak hem de çevreninle uyum içinde olmak istiyorsun. '
          'Duygusal zekan yüksek — insanların söylemediklerini de duyabiliyorsun. '
          'Bu güç, seni özel kılıyor ama bazen de kalabalıktan uzaklaşmak istemen için tam bir neden.',
    ],

    3: [
      'seninle aynı odada olmak insanlara iyi hissettiriyor — bunu kasıtlı yapmıyorsun, sadece oluyorsun. '
          'Yaratıcılığın ve iletişim yeteneğin seni çevrendekiler için hem eğlenceli hem de ilham verici kılıyor. '
          'Fikirler sende hızla doğuyor; sorun onları hayata geçirirken odak tutmak. '
          'İfade etmek — yazmak, konuşmak, yaratmak — senin en doğal nefes alma biçimin. '
          'Duygularını kelimelerle, renklerle ya da sesle dışa vurabildiğinde içinde bir özgürleşme hissediyorsun.',

      'sen hayatı büyük bir tuval gibi görüyorsun ve bu tuvali her rengiyle doldurmak istiyorsun. '
          'Sıkıcı olmak, tekrar etmek, rutine girmek seni bunaltıyor. '
          'İnsanlar senin yanındayken gülerken kendilerini daha hafif hissediyorlar — bu bir mucize değil, senin enerjin. '
          'Bazen çok fazla şey başlayıp hiçbirini bitirememek seni zorlasa da, '
          'başlama cesareti dahi pek çok insanın sahip olmadığı bir şey.',

      'iletişim senin süper gücün. '
          'Doğru kelimeyi, doğru anlatımı bulma yeteneğin seni hem sosyal ortamlarda hem de yaratıcı alanlarda öne çıkarıyor. '
          'İnsanlar sana sırlarını anlatıyor çünkü onları gerçekten dinlediğini hissediyorlar. '
          'Hayata karşı doğal bir merakın var; yeni şeyler öğrenmek, yeni insanlarla tanışmak seni canlı tutuyor. '
          'Kendini ifade etme cesaretin, çevrendekiler için de ilham kaynağına dönüşüyor.',
    ],

    4: [
      'her şeyde sağlam temeller inşa etmek senin için doğal bir içgüdü. '
          'Güvenilir, tutarlı ve planlı yapın seni çevrendekiler için bir kaya gibi hissettiriyor. '
          'İnsanlar bir şeyi sana söylediklerinde unutmayacağını, üstüne düşüneceğini ve geri döneceğini biliyorlar. '
          'Bu güven, pek çok insanın sana sığınmasının nedeni. '
          'Adım adım ilerlemeyi seversin; acele etmek sana göre değil ama bir kez kararın netleştiğinde kararlılığın sarsılmaz.',

      'sen söz verdiğinde tutarsın. Bu basit görünen özellik aslında pek az insanda var. '
          'Düzen ve yapı sana güvenlik hissi veriyor; belirsizlik ise içinde hafif bir rahatsızlık yaratıyor. '
          'Çalışmayı, emek vermeyi, bir şeyi layıkıyla yapmayı içselleştirmişsin. '
          'Sabır senin en büyük silahın — çoğu insan yarı yolda bırakırken sen hedefe ulaşana kadar devam ediyorsun. '
          'Kalıcı olanı, sağlam olanı, gerçek olanı tercih ediyorsun.',

      'pratik zekân ve sistematik düşünce yapın hayatı gerçekten daha iyi hale getiriyor. '
          'Bir problem gördüğünde çözüm üretmek sana doğal geliyor; duygusal tepkilerden çok somut adımları tercih ediyorsun. '
          'Çevrendekiler "ona sorarım, o bilir" ya da "onu aramam yeter" diyor — bu güven duygusu senin için büyük bir değer. '
          'Bazen aşırı sorumlu hissetmek ya da her şeyi kontrol etmek istemek seni yıpratıyor; '
          'ama bu da seni sen yapan şeyin bir parçası.',
    ],

    5: [
      'özgürlük senin için sadece bir kavram değil, bir ihtiyaç. '
          'Değişimden besleniyorsun ve hayatın farklı renklerini keşfetmek seni diri tutuyor. '
          'Rutine girdiğinde ya da sıkışmış hissettiğinde içinde bir alarm çalıyor — bu alarm seni harekete geçiriyor. '
          'Yeni deneyimler, yeni insanlar, yeni fikirler: bunlar senin için oksijen gibi. '
          'Bazen bu çok yönlülük dağınıklık gibi görünse de, aslında yaşamı farklı katmanlarıyla anlama kapasiteni gösteriyor.',

      'sen tek bir yerde, tek bir şekilde kalmaya programlanmamışsın. '
          'Hayat sana ne kadar farklı kapı açarsa, o kadar büyüyorsun. '
          'İnsanlar bazen seni zor anlıyor çünkü bugün istediğin yarın değişebiliyor — ama bu tutarsızlık değil, gelişim. '
          'Risk almaktan çekinmiyorsun; çünkü hareketsiz kalmak senin için en büyük risk. '
          'Macera, büyük şeyler olmak zorunda değil — bazen tanımadığın bir sokağa girmek bile senin için yeterince heyecan verici.',

      'uyum sağlama yeteneğin olağanüstü. '
          'En zor koşullarda bile bir çözüm yolu buluyor, yeni bir başlangıç noktası yaratıyorsun. '
          'Değişim seni korkutmuyor, aksine içinde bir parıltı yakıyor. '
          'Özgürlük ihtiyacın bazen bağlılıklarına zarar verebiliyor ama bu, sevmediğin için değil — '
          'sınırlanmaktan duyduğun derin rahatsızlık yüzünden. '
          'Kendine dürüst olmak, senin en önemli pusulalarından biri.',
    ],

    6: [
      'sevdiklerini korumak ve onlara destek olmak senin için en doğal şey. '
          'Empatin yüksek, kalbinde her zaman başkalarına yer açıyorsun. '
          'Birileri zor bir dönemde olduğunda ilk aklına gelen şey "ne yapabilirim?" oluyor — bu güzellik, sende gerçek. '
          'Sorumluluk duygun güçlü; bazen bu seni yorsa da, aynı sorumluluk seni çevrendekiler için vazgeçilmez kılıyor. '
          'Sevgi senin için hem en güçlü motivasyon hem de en büyük kırılganlık.',

      'sen bir sığınak yaratırsın — insanlar yanında olduğunda daha güvende hissediyor. '
          'Bu his tesadüf değil; sen bunu bilinçli ya da bilinçsiz, sürekli yapıyorsun. '
          'Güzelliği fark etme ve takdir etme yeteneğin var; bir çiçek, bir müzik, bir söz seni gerçekten dokunuyor. '
          'Bazen başkalarına o kadar çok veriyorsun ki kendi bardağının boşaldığını geç fark ediyorsun. '
          'Ama verdiğin her şey, sana farklı bir biçimde geri dönüyor.',

      'uyum ve huzur senin için derin bir ihtiyaç. '
          'Çatışma ortamları seni gerior ve bazen huzuru korumak için kendi ihtiyaçlarından ödün veriyorsun. '
          'Çevrendeki insanların iyiliğini gerçekten önemsiyorsun — bu samimi ilgi, seni farklı kılıyor. '
          'Estetik duygunun gelişmiş olması, hem içinde hem de dışında güzellik yaratma çaban, '
          'seni yaşam kalitesine değer veren biri yapıyor. '
          'Kendinle ilgilenmeyi de sevmek olarak görmeye başladığında, çok daha dengeli hissedeceksin.',
    ],

    7: [
      'yüzeyin altındaki gerçeği görmek senin için bir tutku. '
          'Soru sormak, araştırmak ve derinlemesine düşünmek seni besleyen şeyler. '
          'Çoğu insan "yeterince iyi" derken sen hâlâ "peki ama neden?" diye soruyorsun. '
          'Bu merak seni olağanüstü bir öğrenici yapıyor; ama aynı zamanda zaman zaman seni sonsuz bir düşünce labirentine sokuyor. '
          'Yalnızlık senin için hem bir ihtiyaç hem de en verimli olduğun ortam.',

      'gözlemlemek, analiz etmek, anlamak — bunlar senin dünyayla bağlantı kurma biçimlerin. '
          'Sezgisel düşünce ve mantıksal analizi bir arada taşıyorsun; bu nadir bir kombinasyon. '
          'Güven inşa etmek senin için zaman alıyor ama bir kez kurulduğunda derinlemesine bağlanıyorsun. '
          'Kalabalıktan ziyade birkaç gerçek bağlantıyı tercih ediyorsun. '
          'İçinde sürekli bir anlam arayışı var — ve bu arayış seni hem yoruyor hem de şaşırtıcı yerlere götürüyor.',

      'bilgelik senin için bir hedef değil, doğal bir yolculuk. '
          'Kitaplara, insanlara, deneyimlere olan merakın seni sürekli büyütüyor. '
          'Zaman zaman çevrendekiler seni çok sessiz ya da uzak buluyor ama aslında sen o anlarda en yoğun biçimde düşünüyorsun. '
          'Gerçeği bulmak, sırları çözmek, görünmeyeni görmek — bunlar seni harekete geçiren şeyler. '
          'Dünya görüşün geniş; bu genişlik, seni çevrendekiler için değerli bir rehber yapıyor.',
    ],

    8: [
      'büyük hedefler koyuyorsun ve bunlara ulaşmak için azimle çalışıyorsun. '
          'Başarı ve güç senin için soyut kavramlar değil, somut hedefler. '
          'Zorluklarla karşılaştığında çoğu insan geri çekilirken sen daha da sıkı tutunuyorsun. '
          'Bu azim seni çok ileriye taşıyor ama aynı zamanda dinlenmeni, kendinle nazik olmanı zorlaştırabiliyor. '
          'Başardığında bile "yeterince büyük mü?" diye soruyorsun kendine — bu hem gücün hem de dinmez yorgunluğun kaynağı.',

      'sen doğanın sana verdiği bir güce sahipsin ve bunu iş hayatında, ilişkilerinde, her alanda hissediyorsun. '
          'İnsanlar sana güveniyor çünkü bir şeyin üstesinden geleceğini biliyorlar. '
          'Para, kariyer, başarı — bunları çok somut görüyorsun ve bunlara ulaşmak için stratejik düşünüyorsun. '
          'Ama zaman zaman bu odak, daha ince şeyleri — sezgileri, duyguları, anları — geri plana atıyor. '
          'Güçlü olmak kadar savunmasız olabilmek de seni tamamlıyor.',

      'liderlik ve etki senin için içgüdüsel. '
          'Bir grupta bulunduğunda ya doğal olarak önde yer alıyorsun ya da arkadan yönlendirecek kadar akıllı davranıyorsun. '
          'Maddi dünyada güçlü olmak istiyorsun ama bu sadece hırs değil; derininde bir güvenlik ihtiyacı yatıyor. '
          'Azmin ve disiplinin seni çok uzaklara taşıyacak; tek tehlike, yolda neyin gerçekten önemli olduğunu unutmak. '
          'Başarının tadını en çok paylaşıldığında çıkarıyorsun.',
    ],

    9: [
      'insanlığa duyduğun derin bağ seni özel kılıyor. '
          'Gördüğün yerde iyilik yapmak içinden geldiği için yapıyorsun; bir karşılık beklemiyorsun. '
          'Büyük resmi görebiliyorsun — tek bir olayın arkasındaki bağlantıları, örüntüleri, anlamları. '
          'Bu vizyon seni hem ilham verici bir insan hem de bazen yanlış anlaşılan biri yapıyor. '
          'Tüm insanlığı kucaklamak isterken bazen en yakınındakilere yeterince zaman kalmıyor — bu senin en büyük çelişkin.',

      'sen döngüleri tamamlayan birisin. '
          'Başladığın her şeyde bir anlam arıyorsun ve anlam bulmadan bırakmak seni rahatsız ediyor. '
          'Şefkat senin için hem bir güç hem de bir kırılganlık. '
          'Dünyanın acısını çok derinden hissediyorsun; bu hassasiyet seni hem çok insan hem de çok yorgun yapıyor. '
          'Ama aynı hassasiyet, insanlara şifa verebilme kapasiteni de doğuruyor.',

      'evrensel bir sevgi taşıyorsun — bu soyut bir ifade değil, davranışlarına yansıyan gerçek bir hal. '
          'Farklı insanları, farklı bakış açılarını anlayabiliyorsun; bu empati seni çok değerli bir köprü yapıyor. '
          'Bazen çok fazla şeyi içselleştirip ağır yükler taşıyorsun. '
          'Serbest bırakmayı, tamamlanmışı tamamlanmış saymayı öğrenmek senin için en dönüştürücü pratiği olabilir. '
          'Dünya, sende olduğun gibi değerli biri için daha güzel bir yer.',
    ],
  };

  static const Map<int, String> _depthByDigit = {
    1: 'Kendi yolunu çizerken aslında başkalarına da ışık tuttuğunu zamanla fark ediyorsun. Önderlik etmek, seni hem özgürleştiriyor hem de sorumlu kılıyor.',
    2: 'Sezgilerine güvenmek seni daha güçlü kılıyor. O iç ses çoğunlukla en doğru cevabı biliyor.',
    3: 'Kendini ifade ettiğinde hayatın renkleniyor. Yaratıcılığın bastırıldığında ise içinde bir şeyler solar.',
    4: 'Güçlü temellerin üzerine kurduğun her şey uzun ömürlü oluyor. Sabır ve istikrar, senin en güçlü mirasın.',
    5: 'Her yeni kapı sana yeni bir sen sunuyor. Değişim senin büyümeni mümkün kılan güç.',
    6: 'Verdiğin sevginin bir kısmını kendine vermek seni daha tam hissettiriyor. Kendine şefkat göstermek, bir lüks değil, bir zorunluluk.',
    7: 'Sessizlikte bulduğun cevaplar, dışarıda aradıklarından çok daha değerli. İç dünyanda inanılmaz bir bilgelik var.',
    8: 'Başarının tadını en çok emekle kazanıldığında ve paylaşıldığında çıkarıyorsun. Güç, yalnız taşındığında ağırlaşıyor.',
    9: 'Dünyanın daha iyi bir yer olması için taşıdığın enerji gerçek. Ve bu enerji, farkında olmadan başkalarını da dönüştürüyor.',
  };

  // ─── Güçlü Yönler (H5 = Potansiyel) ────────────────────────────────────────
  static String strength(String name, int h5) {
    final s = _strengthByDigit[h5] ?? _strengthByDigit[1]!;
    return '$name, $s';
  }

  static const Map<int, String> _strengthByDigit = {
    1: 'en büyük gücün inisiyatif alma yeteneğin. Harekete geçmekte tereddüt etmiyorsun ve bu cesaret, çevrendeki insanları da harekete geçiriyor. Liderlik sende dayatılan bir rol değil, içten gelen bir çağrı.',
    2: 'en büyük gücün insanları anlama ve köprü kurma kapasiten. Arabuluculuk sende o kadar doğal ki çoğu zaman yaptığının ne kadar özel olduğunun farkında bile olmuyorsun. Bölünmüş yerleri birleştiriyorsun.',
    3: 'en büyük gücün yaratıcılık ve iletişim. Sözcüklerle, fikirlerle, sesle ya da görsellerle bir büyü yapıyorsun. İnsanları hem anlatımınla hem de enerjinle büyüleyebiliyorsun.',
    4: 'en büyük gücün güvenilirlik ve tutarlılık. İnsanlar sana yaslanabileceğini biliyor çünkü söylediklerinin arkında duruyorsun. Bu güven, paha biçilmez bir değer.',
    5: 'en büyük gücün uyum sağlamak ve fırsatları görmek. Değişim seni köreltmez, aksine keskinleştirir. Başkalarının kriz dediği yerde sen kapı görüyorsun.',
    6: 'en büyük gücün empatin ve şefkatin. Sıcaklığın insanları iyileştiriyor; yanında olduğunda insanlar kendilerini daha güvende hissediyor. Bu iyileştirici enerji, gerçek bir hediye.',
    7: 'en büyük gücün derinlemesine düşünmek ve analiz etmek. Başkalarının göremediği bağlantıları görüyorsun. Bu bakış açısı, seni hem iyi bir problem çözücü hem de değerli bir danışman yapıyor.',
    8: 'en büyük gücün kararlılık ve vizyoner bakış açısı. Büyük resmi görüyor, stratejik düşünüyor ve uzun vadeli hedeflere odaklanabiliyorsun. Bu vizyon seni gerçek bir lider kılıyor.',
    9: 'en büyük gücün şefkat ve vizyon birlikteliği. Hem derinden hissediyorsun hem de geniş bir perspektiften bakabiliyorsun. Bu nadir kombinasyon, seni hem ilham verici hem de güven veren biri yapıyor.',
  };

  // ─── Dikkat Edilmesi Gereken Alan (H6 = Zorluk) ─────────────────────────────
  static String warning(String name, int h6) {
    final w = _warningByDigit[h6] ?? _warningByDigit[1]!;
    return '$name, $w';
  }

  static const Map<int, String> _warningByDigit = {
    1: 'bazen başkalarını dinlemek yerine kendi yolunda çok hızlı ilerlemeye meyil ediyorsun. '
        'Yavaşlamak seni zayıflatmaz; tersine derinleştirir. '
        'Her zaman önde olmak zorunda değilsin — bazen yan yana yürümek de bir liderlik biçimi. '
        'Dinlenmeyi ve durmayı da kendin için hak ettiğin şeyler arasına koyabilirsin.',

    2: 'başkalarının duygularını o kadar derinden hissediyorsun ki zaman zaman kendininkini göz ardı edebiliyorsun. '
        'Kendi ihtiyaçlarına da yer açmak önemli. '
        '"Hayır" demek, ilişkiyi bitirmez; aksine daha sağlıklı kılar. '
        'Başkalarına gösterdiğin anlayışın bir kısmını kendine de gösterebilirsin.',

    3: 'harika fikirlerin bazen dağınık bir enerjiyle buluşuyor. '
        'Odaklanmak ve tamamlamak, başlamak kadar güçlü bir yetkinlik. '
        'Her şeyi aynı anda yapmak zorunda değilsin; bir şeyi iyi yapmak, on şeyi yarım bırakmaktan çok daha tatmin edici. '
        'Sürekli uyarıklık yerine zaman zaman derin bir odak, seni çok daha ileri götürebilir.',

    4: 'her şeyi kontrolünde tutma isteğin zaman zaman seni strese sokabiliyor. '
        'Esnek olmak, plansız olmak anlamına gelmiyor. '
        'Bazen beklenmedik olanı bırakıp akışa girmek, en sağlam planından daha güzel bir yere götürebilir seni. '
        'Kontrol etmediğin şeylerin de güzel olabileceğine güvenmek, büyük bir özgürlük.',

    5: 'köklenme ve bağlılık konusunda zaman zaman çekingen davranıyorsun. '
        'Özgürlük, bağları kesmek zorunda değil. '
        'Derin bir bağlılık içinde bile özgür kalabilirsin; bu ikisi birbirini dışlamaz. '
        'Bir yere ya da birine ait olmak, seni sınırlamaz — seni daha güçlü kılar.',

    6: 'herkesi memnun etmeye çalışmak seni yorabiliyor. '
        '"Hayır" diyebilmek de bir sevgi dilidir — hem kendine hem de karşındakine saygının ifadesi. '
        'Sınır koymak, ilgiyi kesmek değil; ilgiyi sürdürülebilir kılmaktır. '
        'Kendi bardağın boşken başkasına dolduramazsın; önce kendini doldurman gerekiyor.',

    7: 'aşırı analiz kimi zaman harekete geçmeni geciktirebiliyor. '
        'Tüm cevapları bulmadan da ilerleyebilirsin. '
        'Mükemmel plan, çoğu zaman yapılmamış plandan daha az değer taşır. '
        'Bazen en büyük cevaplar, düşünürken değil yaşarken bulunuyor.',

    8: 'başarıya odaklanırken ilişkileri ve küçük anları ikinci plana atabiliyorsun. '
        'En büyük başarın, sevdiklerinle paylaştığın zamandır. '
        'Mola vermek, zayıflık değil — yeniden güçlenmenin yolu. '
        'Kendine izin vermeyi, haketmek için bir sonuç beklemeyi bırakabilirsin.',

    9: 'herkese verirken kendin için bir şey kalmıyor bazen. '
        'Kendini doldurmak da bir sorumluluk — hem kendin için hem de başkalarına verebilmeye devam edebilmek için. '
        'Tüm dünyayı iyileştirmeye çalışırken kendi küçük dünyandaki mutluluğu kaçırabiliyorsun. '
        'Sınırların olmak, sevgini azaltmaz; daha derin ve gerçek kılar.',
  };

  // ─── İlişki Analizi (tüm yorumlar combined pin'den üretilir) ─────────────────

  static String relationshipSummary(
    String name1,
    String name2,
    String type,
    List<int> combined,
  ) {
    final h1 = combined[0];
    final base = _summaryByH1[h1] ?? _summaryByH1[1]!;
    final typeNote = _typeNote(type, name1, name2);
    return '$name1 ve $name2 arasındaki ortak enerji: $base\n\n$typeNote';
  }

  static const Map<int, String> _summaryByH1 = {
    1: 'Güçlü bir liderlik ve öncülük titreşimi taşıyor. Bu ilişkide ikisi de hayatı şekillendiren birer güç — birlikte yarattıklarının etkisi çok daha büyük.',
    2: 'Derin bir sezgisel anlayış ve duygu bağı üzerine kurulu. Kelimeler bazen yetmez ama bakışlarla, sessizlikle anlaşabiliyorsunuz.',
    3: 'Neşe, yaratıcılık ve canlı bir iletişim enerjisi barındırıyor. Birlikte geçirilen zamanlar hem eğlenceli hem ilham verici.',
    4: 'Sağlam bir güven ve kalıcılık temeli üzerinde şekilleniyor. Bu bağ, sarsıntılara dayanacak kadar güçlü inşa edilmiş.',
    5: 'Özgürlük, değişim ve keşif enerjisiyle dolu bir dinamik taşıyor. Bu ilişki sizi her ikisini de büyütüyor.',
    6: 'Şefkat, koruma ve derin bir aidiyet hissiyle örülü. Birbirinizin yanında olmak, en doğal güvenceyi hissettiriyor.',
    7: 'Anlam arayışı, derinlik ve ruhsal bir bağla besleniyor. Bu bağ, sıradan ilişkilerin çok ötesinde bir derinlik taşıyor.',
    8: 'Kararlılık, güç ve ortak büyüme odağını içeriyor. Birlikte hedef koyduğunuzda neredeyse durdurulamazsınız.',
    9: 'Evrensel sevgi ve bütünleşme enerjisiyle yüklü. Bu bağ sadece iki insanı değil, çevrenizdeki herkesi de etkiliyor.',
  };

  static String _typeNote(String type, String name1, String name2) {
    switch (type) {
      case 'Sevgili / Flört':
        return '$name1 ve $name2 arasındaki çekim, bu ortak titreşimin doğal bir yansıması. İki enerjinin birbirini çekmesi tesadüf değil — sayılarda da görünüyor.';
      case 'Evlilik / Eş':
        return 'Bu ortak enerji, yıllara yayılan bir birlikteliğin sağlam zeminini oluşturuyor. Birlikte büyümek, bu ilişkinin en güçlü teması.';
      case 'Eski İlişki':
        return 'Bu ortak kod, ikinizin birbirinden ne öğrendiğini yansıtıyor. O ilişkinin izleri, sizi bugün olduğunuz kişilere dönüştürdü.';
      case 'Arkadaşlık':
        return 'Bu dostluğun temelinde işte bu ortak titreşim yatıyor. Gerçek bir bağlantı — sayılar da bunu doğruluyor.';
      case 'Aile İlişkisi':
        return 'Aile bağınızdaki bu ortak enerji, ilişkinizin rengini ve derinliğini belirliyor. Kan bağının ötesinde, ruhsal bir köprü var aranızda.';
      case 'İş Ortaklığı':
        return 'Bu ortak enerji, profesyonel ilişkinizin en güçlü dayanağı olabilir. Farklı güçleriniz, doğru kanallandığında olağanüstü sonuçlar doğuruyor.';
      case 'Anne - Çocuk':
        return 'Bu bağdaki koşulsuz sevgi ve derin anlayış, ortak kodunuzda açıkça görünüyor. Annelik enerjisi ile çocuğun özgün ruhu burada buluşuyor.';
      case 'Baba - Çocuk':
        return 'Bu kodun güçlü ve sağlam temeli, bağınızdaki güveni ve yönlendirici enerjiyi yansıtıyor. Köklenmek ve büyümek, bu ilişkinin özünde var.';
      default:
        return 'Bu ortak titreşim, ikinize özgü güzel ve özgün bir dinamik oluşturuyor.';
    }
  }

  static String harmonyPoint(String name1, String name2, List<int> combined) {
    final h5 = combined[4];
    final point = _harmonyByH5[h5] ?? _harmonyByH5[1]!;
    return '$name1 ve $name2\'nın ortak potansiyeli: $point';
  }

  static const Map<int, String> _harmonyByH5 = {
    1: 'Birlikte harekete geçtiğinizde güçlü bir etki yaratıyorsunuz. Ortak bir hedef koyduğunuzda birbirinizin enerjisini katlayanlar gibi davranıyorsunuz. Bu sinerji, sizi çevrendeki insanlara da ilham veren bir ikili yapıyor.',
    2: 'Birbirinizi kelimesiz anlayabiliyorsunuz — bu nadir bir hediye. Sezgisel bağınız o kadar güçlü ki, zor anlarda bile sessizliğiniz bile yeterli oluyor. Bu derin empati, ilişkinizin en güzel tarafı.',
    3: 'Birlikte zaman geçirdiğinizde, paylaştığınızda ve yarattığınızda bu bağ zirveye ulaşıyor. Neşeli ve yaratıcı enerjiniz birleşince ortam değişiyor. İnsanlar sizinle vakit geçirdikten sonra daha iyi hissediyor.',
    4: 'Güvenilirlik ve tutarlılık bu ilişkinin en sağlam dayanağı. Birbirinize söz verdiğinizde tutuyorsunuz — ve bu güven, zamanla paha biçilmez bir temel oluşturuyor. Uzun vadeli her projede birlikte güçsünüz.',
    5: 'Birlikte yeni şeyler keşfetmek sizi hem birbirinize bağlıyor hem de her ikinizi büyütüyor. Macera ve değişim bu ilişkiyi canlı tutuyor. Birlikte gittiğiniz her yeni yerde biraz daha birbirinizi ve kendinizi tanıyorsunuz.',
    6: 'Birbirinize şefkat göstermek ve destek olmak bu ilişkide en doğal haliyle akıyor. Zor anlarda yanında olmak, sizi birbirine daha da bağlıyor. Bu sıcaklık ve güvende hissettirme kapasitesi, ilişkinizin en değerli hazinesi.',
    7: 'Derin sohbetler ve anlamlı sorular bu bağı besliyor. Yüzeyde kalmak ikisine de yetmiyor — derinleşmek, bu ilişkinin doğasında var. Entelektüel ve ruhsal uyumunuz, sizi çok güzel bir zemine oturtuyor.',
    8: 'Ortak hedefler koyduğunuzda bu enerji zirveye çıkıyor. Birlikte büyümeye ve başarmaya programlısınız. Destekleyici rekabetin, birbirinizi olduğunuzun en iyisi olmaya itmek için ne kadar güçlü bir araç olduğunu zamanla daha da iyi anlayacaksınız.',
    9: 'Birlikte anlam yarattığınızda bu bağ en parlak haline geliyor. İkisinin de büyük resme bakma kapasitesi, sizi sıradan bir ikili olmaktan çok daha öteye taşıyor. Bu ilişki, sadece sizin için değil çevreniz için de güzel şeyler yaratma gücü taşıyor.',
  };

  static String challengePoint(String name1, String name2, List<int> combined) {
    final h6 = combined[5];
    final challenge = _challengeByH6[h6] ?? _challengeByH6[1]!;
    return '$name1 ve $name2\'nın büyüme alanı: $challenge';
  }

  static const Map<int, String> _challengeByH6 = {
    1: 'Bu ilişkide ikisi de önde olmak ve yönlendirmek isteyebiliyor. Bu, çatışmaya değil — rollerin netleştirilmesine davet. Kimin ne zaman öne geçeceğini birlikte belirlemek, ilişkiyi hem dengeli hem de güçlü kılıyor.',
    2: 'Duygusal ihtiyaçları dile getirmek bazen zor geliyor. İkisi de karşısındakinin anlamasını beklerken, açıkça söylemek gerekiyor. Varsayımlar yerine sorular sormak, bu ilişkiyi çok daha derin bir anlayışa taşıyor.',
    3: 'Odak ve tamamlama konusunda birbirinizi desteklemek gerekebiliyor. Başlamak güzel ama devam etmek ve tamamlamak bu ilişkinin büyüme alanı. Birbirinizi bu konuda nazikçe hatırlatıcı olmak, en güzel desteklerden biri.',
    4: 'Esneklik bu ilişkinin en önemli büyüme alanı. Planlar güzel ama planlanmayanlar da bazen en güzel şeyleri getiriyor. Birbirinize ve yaşama biraz daha alan açmak, ilişkiye yeni bir nefes kazandırıyor.',
    5: 'Köklenme ve uzun vadeli bağlılık konusunda ortak bir zemin bulmak gerekiyor. Özgürlük ve bağlılık birbirinin zıttı değil — ikisini birlikte taşıyabileceğiniz bir şekil bulmak, bu ilişkinin en güzel dönüşümü olabilir.',
    6: 'Her ikisi de başkalarını öncelikli tutmaya meyilli olabiliyor. Birbirinize "hayır" diyebilmek, ilişkiyi zayıflatmaz — daha sağlıklı ve sürdürülebilir kılar. Kendi ihtiyaçlarını da önemsemek, bu bağa yapılan en güzel yatırım.',
    7: 'Aşırı düşünmek ve analiz etmek bazen hareketi engelleyebiliyor. Bazen bırakmak, çözmekten daha güçlüdür. Bu ilişkide kafa yerine kalbe vermek, duraksanan yerlerde akışı yeniden başlatıyor.',
    8: 'Başarı ve hedef odağı ilişkinin duygusal tarafını zaman zaman geri plana itebiliyor. Performans değil bağ, bu ilişkinin gerçek temeli. Birlikte durup sadece "burada olmak" için zaman ayırmak, her şeyi dengede tutuyor.',
    9: 'Başkalarına verirken birbirinize de enerji ve zaman ayırmak önemli. Bu bağ da beslenmeye ihtiyaç duyuyor. Dünyanın iyiliği için çalışırken, en küçük dünyanız olan bu ilişkiye de özen göstermek gerekiyor.',
  };

  // ─── Cinsel Uyum (sadece Sevgili/Flört, Evlilik/Eş, Eski İlişki) ────────────
  /// [fire] = combined pin'deki ateş sayısı, [dominantScore] baskın enerji,
  /// [energyType] = combined enerjisi, tüm değerler combined pin'den gelir.
  static String sexualCompatibilityTeaser(
    String name1,
    String name2,
    int fire,
    int water,
    int air,
    String energyType,
  ) {
    final level = _sexualLevel(fire, water, air, energyType);
    return _sexualTeasers[level]!
        .replaceAll('{n1}', name1)
        .replaceAll('{n2}', name2);
  }

  static String _sexualLevel(
      int fire, int water, int air, String energyType) {
    if (fire >= 3) return 'very_high';
    if (fire == 2 && energyType == 'Baskın') return 'high';
    if (fire == 2) return 'high_moderate';
    if (water >= 3) return 'emotional_deep';
    if (air >= 3) return 'intellectual';
    if (fire == 1 && water >= 2) return 'moderate_warm';
    return 'harmonious';
  }

  static const Map<String, String> _sexualTeasers = {
    'very_high':
        '{n1} ve {n2} arasında fiziksel çekim enerjisi son derece güçlü. '
        'Ortak pin kodunda Ateş elementi belirgin biçimde öne çıkıyor — '
        'bu, ikili arasındaki fiziksel uyumun ve tutkunun doğal bir yansıması. '
        'Bu enerji doğru beslendiğinde ilişkiye sürekli canlılık katıyor.',

    'high':
        '{n1} ve {n2} arasında güçlü bir fiziksel çekim enerjisi var. '
        'Ateş elementi ve baskın enerji bir arada — bu ilişkide tutku, '
        'spontanlık ve fiziksel bağlantı önemli bir yer tutuyor. '
        'Bu enerjiyi hem birbirinizi keşfetmek hem de ilişkiyi beslemek için kullanabilirsiniz.',

    'high_moderate':
        '{n1} ve {n2} arasında sıcak ve istekli bir fiziksel bağlantı var. '
        'Ortak kodunuzdaki Ateş enerjisi ikinizi birbirine yaklaştırıyor; '
        'bu ilişkide fiziksel yakınlık hem rahatlatıcı hem de heyecan verici.',

    'emotional_deep':
        '{n1} ve {n2} arasındaki fiziksel bağ duyguyla iç içe. '
        'Su elementinin güçlü oluşu, fiziksel yakınlığın duygusal derinlikle '
        'birleştiğini gösteriyor. Bu bağda güven ve duygusal açıklık, '
        'fiziksel uyumu doğal olarak güçlendiriyor.',

    'intellectual':
        '{n1} ve {n2} arasındaki fiziksel çekim zihinsel bağlantıyla besleniyor. '
        'Hava elementinin öne çıkması, fiziksel uyumun iletişim ve anlayışla '
        'derinleştiğini gösteriyor. Birbirinizle konuşmak, birbirinize yakın hissetmenin en güçlü yolu.',

    'moderate_warm':
        '{n1} ve {n2} arasında sıcak ve dengeli bir fiziksel bağlantı var. '
        'Ateş ve Su elementlerinin bir araya gelmesi, tutku ile duygusallığın '
        'iç içe geçtiğini gösteriyor — bu ilişkide fiziksel yakınlık zaman içinde derinleşiyor.',

    'harmonious':
        '{n1} ve {n2} arasındaki fiziksel bağlantı dengeli ve uyumlu. '
        'Ortak kodunuz, güven ve istikrarın fiziksel uyumun temelini oluşturduğunu '
        'gösteriyor. Birlikte büyüdükçe bu bağ da güçleniyor.',
  };

  // Cinsel uyumu göstermesi gereken ilişki türleri
  static bool showSexualCompatibility(String relationshipType) {
    return relationshipType == 'Sevgili / Flört' ||
        relationshipType == 'Evlilik / Eş' ||
        relationshipType == 'Eski İlişki';
  }

  // ─── Ortak Pin Kodu Özet Yorumu ───────────────────────────────────────────────
  static String combinedInsight(
    String name1,
    String name2,
    List<int> combined,
  ) {
    final h1 = combined[0];
    final h5 = combined[4];
    final h9 = combined[8];

    final base = _combinedBaseByDigit[h1] ?? _combinedBaseByDigit[1]!;
    final potential = _combinedPotentialByDigit[h5] ?? _combinedPotentialByDigit[1]!;
    final essence = _combinedEssenceByDigit[h9] ?? _combinedEssenceByDigit[1]!;

    return '$name1 ve $name2\'nın ortak enerjisi $base $potential $essence';
  }

  static const Map<int, String> _combinedBaseByDigit = {
    1: 'güçlü bir inisiyatif ve öncülük titreşimi taşıyor.',
    2: 'derin bir duygu bağı ve sezgisel anlayış üzerine kurulu.',
    3: 'neşe, yaratıcılık ve paylaşım enerjisiyle dolu.',
    4: 'sağlam temeller, güven ve kalıcılık üzerine inşa ediliyor.',
    5: 'özgürlük, keşif ve sürekli dönüşüm enerjisi taşıyor.',
    6: 'şefkat, koruma ve derin bir aidiyet hissiyle örülü.',
    7: 'derinlik, anlam arayışı ve ruhsal bir bağla besleniyor.',
    8: 'güç, kararlılık ve büyüme odaklı bir dinamik içeriyor.',
    9: 'evrensel sevgi, bütünleşme ve anlam dolu bir enerji taşıyor.',
  };

  static const Map<int, String> _combinedPotentialByDigit = {
    1: 'Birlikte harekete geçtiğinizde güçlü bir etki yaratıyorsunuz.',
    2: 'Birbirinizi dinlediğinizde bu bağ derinleşiyor.',
    3: 'Birlikte geçirdiğiniz her an her ikinize de ilham veriyor.',
    4: 'Ortak kararlarınız uzun vadede sağlam sonuçlar doğuruyor.',
    5: 'Birlikte yeni deneyimler yaşadıkça bu bağ güçleniyor.',
    6: 'Birbirinize verdiğiniz destek her ikinizi de iyileştiriyor.',
    7: 'Derin sohbetler ve sessiz anlar bu bağı besliyor.',
    8: 'Ortak hedefler koyduğunuzda bu enerji zirveye çıkıyor.',
    9: 'Birlikte anlam yarattığınızda bu bağ en parlak haline geliyor.',
  };

  static const Map<int, String> _combinedEssenceByDigit = {
    1: 'Bu ilişkinin özünde birbirini güçlendiren iki lider var.',
    2: 'Bu ilişkinin özünde köklü ve derin bir duygu bağı yatıyor.',
    3: 'Bu ilişkinin özünde tükenmez bir yaratıcı enerji var.',
    4: 'Bu ilişkinin özünde güçlü bir güven ve istikrar var.',
    5: 'Bu ilişkinin özünde birbirini özgür bırakan bir bağ var.',
    6: 'Bu ilişkinin özünde koşulsuz bir sevgi enerjisi yatıyor.',
    7: 'Bu ilişkinin özünde ruhsal ve zihinsel bir derinlik var.',
    8: 'Bu ilişkinin özünde birbirini büyüten güçlü bir irade var.',
    9: 'Bu ilişkinin özünde insanlığa dokunan bir sevgi enerjisi var.',
  };

  // ─── Günlük İçgörüler (30 giriş) ────────────────────────────────────────────
  static const List<String> dailyInsights = [
    'Bugün kendi sınırlarını daha net hissetmen gereken bir gün. Herkesi memnun etmeye çalışmak seni yorabilir; enerjini biraz daha kendine yönelt.',
    'Bugün içgüdülerine güvenmek için güzel bir gün. Aklın ile kalbinin aynı şeyi söylediğinde tereddüt etme.',
    'Küçük adımlar büyük fark yaratır. Bugün bir şeyi bitirmek, on şeyi başlamaktan çok daha güçlü.',
    'Dinlemek, konuşmak kadar güçlü bir eylemdir. Bugün birinin sözlerine gerçekten kulak ver — sadece cevap vermek için değil, anlamak için.',
    'Kendine karşı nazik olmayı hatırla. Başkalarına gösterdiğin anlayışın bir kısmını bugün kendine göster.',
    'Bugün değişime açık ol. Planın olmayan bir şey seni beklenmedik güzel bir yere götürebilir.',
    'Minnet, enerjiyi yükseltir. Bugün üç küçük şeye şükretmek, gününün rengini değiştirebilir.',
    '"Hayır" demek de bazen en güçlü "evet"tir. Sınırların seni zayıflatmaz, korur.',
    'Bugün merakla bak. En sıradan şeylerde bile keşfedilmeyi bekleyen güzellikler var.',
    'Sessizlik içinde de büyüyorsun. Bugün biraz kendinle kal ve içindeki sesi dinle.',
    'İlişkilerinde önce dinle, sonra konuş. Anlaşılmak, haklı çıkmaktan çok daha tatmin edici.',
    'Bugün kendin için küçük de olsa bir şey yap. Kendi mutluluğun da bir öncelik.',
    'Geçmiş seni tanımlamak zorunda değil. Bugün yaptıkların, kim olduğunu şekillendiriyor.',
    'Güven tek seferde inşa edilmez. Bugün tutarlılığınla bir adım at.',
    'Mükemmel olmak zorunda değilsin. Yeterince iyi olmak, bazen en derin özgürlük.',
    'Bugün birisine beklenmedik bir iyilik yap. Küçük jestler bazen en kalıcı izleri bırakıyor.',
    'Korkuyla değil, merakla yaklaş bugünkü zorluklara. Merak, çözümün kapısını aralıyor.',
    'Bedenini dinle bugün. Yeterince uyku, su ve nefes — bunlar basit görünür ama temeli oluşturur.',
    'Bugün bir şeyi bırakmak için doğru an olabilir. Tutmak kadar bırakmak da güç gerektirir.',
    'Kendinle nasıl konuştuğuna dikkat et. İç sesin, seni en çok etkileyen sestir.',
    'Bugün birinin gözünden dünyaya bakmayı dene. Farklı bir pencere, her şeyi değiştirebilir.',
    'Sabır, zayıflık değil; gücün en derin hali. Bugün sabırlı olmak için bir fırsat çıkabilir.',
    'Bugün doğada biraz zaman geçir — küçük de olsa. Topraklanmak, her şeyi yeniden netleştiriyor.',
    'Hayatındaki insanlara minnettarlığını ifade etmek için bugün doğru an olabilir.',
    'Hata yapmak, öğrenmenin en dürüst yolu. Bugünkü hatalarına nazikçe bak.',
    'Bugün bir hedef belirle — ulaşılabilir, küçük ama anlamlı. Adım adım gelen her şey kalıcı.',
    'Karşılaştırma enerjini tüketir. Bugün sadece dünkü kendinle kıyas yap.',
    'Yaratıcılığın için bugün küçük bir alan aç — bir cümle, bir renk, bir melodi bile yeterli.',
    'Bugün bir sınırını onurla koru. Sınır koymak, sevgiyi azaltmaz; gerçek kılar.',
    'Bu gün bir daha gelmeyecek. Tam burada, tam şimdi olmak için küçük bir an bul.',
  ];

  static String getDailyInsight(DateTime date) {
    final index = (date.day + date.month + date.year) % dailyInsights.length;
    return dailyInsights[index];
  }

  // ─── Haftalık Temalar (12 giriş) ─────────────────────────────────────────────
  static const List<String> weeklyThemes = [
    'Bu hafta odağın: İç ses ile dış dünya arasında denge',
    'Bu hafta odağın: Köklenme ve güvenli zemin',
    'Bu hafta odağın: İletişim ve açık kalplilik',
    'Bu hafta odağın: Serbest bırakmak ve akışa izin vermek',
    'Bu hafta odağın: Özgüven ve kendi değerini tanımak',
    'Bu hafta odağın: Sınırlar ve öz saygı',
    'Bu hafta odağın: Şükran ve farkındalık',
    'Bu hafta odağın: Değişim ve dönüşüme açık olmak',
    'Bu hafta odağın: Derin bağlantılar ve gerçek ilişkiler',
    'Bu hafta odağın: Yaratıcılık ve kendini ifade etmek',
    'Bu hafta odağın: Dinlenme ve yenilenme',
    'Bu hafta odağın: Hedefler ve kararlı adımlar',
  ];

  static String getWeeklyTheme(DateTime date) {
    final weekIndex = ((date.month - 1) + (date.day ~/ 7)) % weeklyThemes.length;
    return weeklyThemes[weekIndex];
  }

  // ─── Olumlamalar (21 giriş) ───────────────────────────────────────────────────
  static const List<String> affirmations = [
    'Ben yeterliyim, tam da olduğum haliyle.',
    'Her gün biraz daha kendim oluyorum.',
    'Kendi sesime güveniyorum.',
    'Değişim beni güçlendiriyor, yıkmıyor.',
    'Sevgiye layığım ve sevgiyle ilerliyorum.',
    'Kendi iyiliğim için cesur seçimler yapabiliyorum.',
    'Bugün, olduğum en iyi halimim.',
    'Hatalarım beni tanımlamaz; onlardan öğreniyor ve büyüyorum.',
    'Sınırlarım beni koruyor ve güçlü kılıyor.',
    'İçimdeki huzuru dışarıdan bir şeye bağlamıyorum.',
    'Kendime karşı nazik olmak, güçlü olmakla çelişmiyor.',
    'Yavaşlamak, durmak değil — derinleşmek.',
    'Her zor deneyim beni daha tam bir insan yapıyor.',
    'Bağlılık ve özgürlük bir arada var olabilir hayatımda.',
    'Başkalarına verdiğim değeri kendime de veriyorum.',
    'Güzel şeyler için sabır gösterebiliyorum.',
    'Tam şu an, tam burada olmak yeterli.',
    'Korkuyla değil, merakla ilerliyorum.',
    'Duygularım geçici; özüm güçlü ve kararlı.',
    'Kendimi onaylamak için başkasının iznine ihtiyacım yok.',
    'Her yeni gün, yeniden başlamak için bir fırsat.',
  ];

  static String getAffirmation(DateTime date) {
    final index = (date.day + date.month + date.year) % affirmations.length;
    return affirmations[index];
  }
}
