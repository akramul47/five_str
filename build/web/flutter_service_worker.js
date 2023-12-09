'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "edced4f514a365a0823606d5aa70c392",
"assets/AssetManifest.json": "e25e19d74f9f48adafb55cbd97059fe4",
"assets/FontManifest.json": "a0a3437493bda9ea6dd0975490a2e100",
"assets/fonts/andina.ttf": "2349c4ffb7293b5f88e8538ec577a8d4",
"assets/fonts/googlesansebold.ttf": "4457817ac2b9993c65e81aa05828fe9c",
"assets/fonts/googlesansmedium.ttf": "8d57e4014b18edef070d285746485115",
"assets/fonts/googlesansregular.ttf": "b5c77a6aed75cdad9489effd0d5ea411",
"assets/fonts/MaterialIcons-Regular.otf": "f038fc3316921eb47e09ddbfa34f1ae7",
"assets/images/coffee-cup.png": "411b263df281237e77bba3b2ea7195bb",
"assets/images/fs_walk1.png": "9946aa5097579c440b764f028901686b",
"assets/images/fs_walk2.png": "3448d6bcab8b28f5f966071dc996c35f",
"assets/images/fs_walk3.png": "644608c9f8c12705b4be1faf7f29b155",
"assets/images/laundry_app_logo.png": "158b2427607d5ce04af77ef75b083837",
"assets/images/LSWall.png": "89f637e010c4ca0d0f0c5ee35a236904",
"assets/images/ls_bedding.png": "e4480436961515c967a2498c3e5c5ec0",
"assets/images/ls_BedSheets.png": "9ef3a132ce4940bf42be22158ec34046",
"assets/images/ls_bgRefer.png": "59c785b5e643c3b55bfa030377e700c6",
"assets/images/ls_bgWalk1.png": "fb21deaedd9f6fc1456d1ee3d1ccb138",
"assets/images/ls_bgWalk2.png": "4b4f55f75e4cf2646b0d921884662af1",
"assets/images/ls_bgWalk3.png": "a9d45a8552c4624a5a4029848d197ab6",
"assets/images/ls_bgWalk4.png": "7c0cd44ba55babe128e6f49c2e20c384",
"assets/images/ls_bgWalk5.png": "4c05499b4c5aa84579efd8256b65930b",
"assets/images/ls_clean.png": "6795749a651b51d61d3ca1cd87431bd0",
"assets/images/ls_clear.png": "5efc6c758fd9368ac7c947899a1df06f",
"assets/images/ls_confirm.png": "260d341d4a7de94111dca036a997a0db",
"assets/images/ls_correct.png": "291c184439f41c3272add890be7710c5",
"assets/images/ls_delivery_van.png": "a6c82327b916438cf3dc3a9d552f99d3",
"assets/images/ls_Dress.png": "38497409fd8c39b00fa01c5b86f40275",
"assets/images/ls_fb.png": "de0f868484943a81c66fcc0681e0b50e",
"assets/images/ls_forgot.png": "a16890c107aaff83a0bf2a606d9fed11",
"assets/images/ls_google.png": "eefb0444778c50607765783dea76e7be",
"assets/images/ls_household.png": "2da3d3b6679f41088e0d7a8ef4a427d8",
"assets/images/ls_ic_basket.svg": "b012afca90da136e9a2ec9901f90e1e8",
"assets/images/ls_ic_home.svg": "3571e7455c73db4428162c4b654bdad2",
"assets/images/ls_ic_pin.svg": "fda3ce86be194f0a418f645df8bba7f3",
"assets/images/ls_ic_sale.svg": "b63e0e9bc629601dada46609083b63d1",
"assets/images/ls_ic_user.svg": "539ade4fdb3058f7fb13ef206dd7c36b",
"assets/images/ls_in_progress.png": "85928e59eaf9e27c20095b13c7554a1a",
"assets/images/ls_Iron.png": "d219cf3d5e3cb41b4c5fbd9092769b1a",
"assets/images/ls_Jacket.png": "24fea4ee2a0237aa6214dc128e71b239",
"assets/images/ls_Jeans.png": "23500e51effcaf0bb774d7bf2bf82893",
"assets/images/ls_Laundry.png": "67b39ca93a7ae8e16b4003a872ddefb2",
"assets/images/ls_list1.jpeg": "412b07f27be0c7cd22e05f0c4dd179d1",
"assets/images/ls_list2.jpeg": "3ed34df0cd238c32a10d88e6ea137a98",
"assets/images/ls_list3.png": "87a26486e42cd7c62c012705fe3f6af9",
"assets/images/ls_list4.jpeg": "8d59bcd48b2ba4b7174e3ac4f238b0f8",
"assets/images/ls_list5.jpeg": "1a3ffa001b6dfc7f2e330818c95158ef",
"assets/images/ls_logo.png": "302eff90b7d6e8482653f7b171253f80",
"assets/images/ls_Man.png": "f036ae67387dc6665a064ff6cc6f9d7f",
"assets/images/ls_Map.jpeg": "5e5df70005a7c14372b13fe7151b1412",
"assets/images/ls_pickup.png": "a378737b64d344bb62f4b3b589999b8d",
"assets/images/ls_profile.jpeg": "a0153b0e786d26224fa27191b2baa39d",
"assets/images/ls_profileBg.jpeg": "abec28a4d5b2069f962d977eb7676582",
"assets/images/ls_Refer.png": "e5c8343f2b9e0ea3090ba5bcc162ff25",
"assets/images/ls_remove.png": "fdd28a15b6bf385aa4b8ce1b62ad2aa0",
"assets/images/ls_reset.png": "10b848bd1d02ad955e8f1330e41a2175",
"assets/images/ls_Sari.png": "896caa19c6e54c7f783740aa20050200",
"assets/images/ls_shipping.png": "55cf9c885f1e4cda871c9e44a149f7b6",
"assets/images/ls_Shirt.png": "1a469142e3f5ad5f58021cb8e7ba5ced",
"assets/images/ls_Shirts.png": "00ea1b4022c9c9a34495e1e51a64499e",
"assets/images/ls_Shot.png": "74d48d02424d98e3438a314b37ea1ad2",
"assets/images/ls_suit.png": "91874f97089cc2c421bdc56ba517f91d",
"assets/images/ls_Sweatshirt.png": "3d42c9f5ebfc4c490f5c56b596ec27bc",
"assets/images/ls_Towel.png": "c4733edd3077932c22daf7b63ed1837a",
"assets/images/ls_Towels.png": "f2aa2ea0cceff34fe06d89edaecf2cdc",
"assets/images/ls_van.png": "f1df4a192d8433912a51e245fe9689ed",
"assets/images/ls_verify.png": "40d3c773ebb213dc52eebfc9c08a9296",
"assets/images/ls_walk1.png": "483748123337d3719b094888ec9cf142",
"assets/images/ls_walk2.png": "f6b30c71b51f6cc70e97b06e4c5d6d87",
"assets/images/ls_walk3.png": "bd1989a3d5fea4b618d7d28e6c4d686b",
"assets/images/ls_walk4.png": "acb48b5f21ee551eeb7040c59e34c7d1",
"assets/images/ls_walk5.png": "782b31ee04f9f37da4dbb53ebaf19578",
"assets/images/ls_washing_clothes.png": "56a2c6064a2b71ab36298b5433f09e04",
"assets/images/ls_washing_machine.png": "b33bfdbb37b7165f6710c29d725b9045",
"assets/images/ls_wash_service.png": "59f98aa81ce2bcf22098c3386d7db5bb",
"assets/images/ls_water_supply.png": "522b833dbd3e568bc7e0c0f6653476be",
"assets/images/ls_Woman.png": "388423fe86ad080ad3fa3a9bd16a2e2a",
"assets/images/ls_women.png": "e008ad4fb310cb3398f49b14e2f3f68c",
"assets/images/online-shopping.png": "5f744fbc2d95aaa855b6be79a4656d0a",
"assets/images/placeholder.jpg": "0d76c36102ab7301fb582fe101acb506",
"assets/images/restaurant.png": "baf4a3a4ab91b573dd824279f133f794",
"assets/images/restaurant1.jpg": "3116c78a500bd1e41b271f35c4494e4a",
"assets/images/restaurant2.jpg": "10edce9a0bc492f1b99d55a435866b5a",
"assets/images/restaurant3.jpg": "5a696f7ad38dc24b046e54a74db63e5a",
"assets/images/restaurant4.jpg": "0138867bf24cede48ba0c64904c95b26",
"assets/images/review.svg": "c7580e0cf96bf4cf1162b003caff0b60",
"assets/images/search.svg": "c20a7a6afb0e1ff538dec7f63676e188",
"assets/NOTICES": "d5f89cfda3ef34e3d70c3cbb8904cf1d",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "89ed8f4e49bcdfc0b5bfc9b24591e347",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/packages/flutter_vector_icons/fonts/AntDesign.ttf": "3a2ba31570920eeb9b1d217cabe58315",
"assets/packages/flutter_vector_icons/fonts/Entypo.ttf": "744ce60078c17d86006dd0edabcd59a7",
"assets/packages/flutter_vector_icons/fonts/EvilIcons.ttf": "140c53a7643ea949007aa9a282153849",
"assets/packages/flutter_vector_icons/fonts/Feather.ttf": "e766963327e0a89f9ec2ba88646b6177",
"assets/packages/flutter_vector_icons/fonts/FontAwesome.ttf": "b06871f281fee6b241d60582ae9369b9",
"assets/packages/flutter_vector_icons/fonts/FontAwesome5_Brands.ttf": "13685372945d816a2b474fc082fd9aaa",
"assets/packages/flutter_vector_icons/fonts/FontAwesome5_Regular.ttf": "db78b9359171f24936b16d84f63af378",
"assets/packages/flutter_vector_icons/fonts/FontAwesome5_Solid.ttf": "1ab236ed440ee51810c56bd16628aef0",
"assets/packages/flutter_vector_icons/fonts/Fontisto.ttf": "b49ae8ab2dbccb02c4d11caaacf09eab",
"assets/packages/flutter_vector_icons/fonts/Foundation.ttf": "e20945d7c929279ef7a6f1db184a4470",
"assets/packages/flutter_vector_icons/fonts/Ionicons.ttf": "b3263095df30cb7db78c613e73f9499a",
"assets/packages/flutter_vector_icons/fonts/MaterialCommunityIcons.ttf": "6a2ddad1092a0a1c326b6d0e738e682b",
"assets/packages/flutter_vector_icons/fonts/MaterialIcons.ttf": "8ef52a15e44481b41e7db3c7eaf9bb83",
"assets/packages/flutter_vector_icons/fonts/Octicons.ttf": "8e7f807ef943bff1f6d3c2c6e0f3769e",
"assets/packages/flutter_vector_icons/fonts/SimpleLineIcons.ttf": "d2285965fe34b05465047401b8595dd0",
"assets/packages/flutter_vector_icons/fonts/Zocial.ttf": "5cdf883b18a5651a29a4d1ef276d2457",
"assets/packages/nb_utils/fonts/LineAwesome.ttf": "4fe1928e582fd2e3316275954fc92e86",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/apple-touch-icon.png": "0e9aaf68a00d52bb2abb9a31a0b8de0b",
"icons/favicon.ico": "64b87a2e47151f722e698ef745643639",
"icons/icon-192-maskable.png": "fc5ef5a9488de49b8607eb79a4214e05",
"icons/icon-192.png": "34da2f0e565213ae5d3b564faec3e972",
"icons/icon-512-maskable.png": "5e4f18cb2eb4c841635b855eb9a69837",
"icons/icon-512.png": "f87b39230add1b047c0b081fa5c251f4",
"index.html": "21d14e991f67b142789321591553e5d4",
"/": "21d14e991f67b142789321591553e5d4",
"main.dart.js": "ba804a6ac73d03f30e9ac83d257619f6",
"manifest.json": "11a01f88b1d8b090a7c4a040e3be72e6",
"splash/img/dark-1x.png": "c78e3953b2332b7be6bb943a5b76c6ab",
"splash/img/dark-2x.png": "ef3d223ccd51ed80ece2078940e106bd",
"splash/img/dark-3x.png": "8eaaad4a92d0846fc4be4cb780d1a022",
"splash/img/dark-4x.png": "b672bcde4caa73e1ad74549b914ec277",
"splash/img/light-1x.png": "c78e3953b2332b7be6bb943a5b76c6ab",
"splash/img/light-2x.png": "ef3d223ccd51ed80ece2078940e106bd",
"splash/img/light-3x.png": "8eaaad4a92d0846fc4be4cb780d1a022",
"splash/img/light-4x.png": "b672bcde4caa73e1ad74549b914ec277",
"splash/style.css": "d4198f3312b6f480da2da5610d5043e5",
"version.json": "cda182302913bc4005c42079fa8a562d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
