Airtime script
==============

collect Airtime - with newer Gluon respondd 

actually we reuse airtime basic script written for old gluon 2015.1 from announced from https://github.com/ffgtso/ffgt_packages-v2015.1/tree/master/gluon-airtime
and make a cronjob to gather data in /tmp folder, most important /tmp/act2 (which is active in seconds) and /tmp/bus2 (which is busy in seconds = rx and tx together) .. so with a little bit of math you can get averages ..

we do a little micron.d cronjob to run it often ...
the script generate some files similar to this
```
0 root@fuzzle_solar:/tmp/xtra# head -n1 *
==> 2gbus <==
13621
==> 2gbus24h <==
42112
==> 2gbus24havg <==
8367
==> 2gbus24hmax <==
1018
==> 2gbus24hmin <==
988
==> 2gtotal <==
59892
==> 2gtotal24h <==
268010
==> 2gtotal24havg <==
2712
==> 2gtotal24hmax <==
1800
==> 2gtotal24hmin <==
7279
==> 2gtx <==
2949
==> 2gtx24h <==
11436
==> 2gtx24havg <==
2712
==> 2gtx24hmax <==
107
==> 2gtx24hmin <==
83
==> batif <==
ibss0
==> batttvn <==
239
==> channel <==
1
```

now we need respondd to also collect these data, i have a running version - but this meant i had to compile it in the beginning, hope for other solutions .. otherwise we need a patch before we build actual firmware. The patch is quiet simple.
in gluon-respondd/src we add some lines the block **static struct json_object * respondd_provider_nodeinfo(void) {**

a patch could look like this 
```c
Index: gluon/package/gluon-respondd/src/respondd.c
===================================================================
--- gluon.orig/package/gluon-respondd/src/respondd.c    2016-06-13 23:28:45.849960883 +0200
+++ gluon/package/gluon-respondd/src/respondd.c 2016-06-13 23:30:11.113082001 +0200
@@ -97,6 +97,24 @@
        json_object_object_add(software, "firmware", software_firmware);
        json_object_object_add(ret, "software", software);
 
+        struct json_object *wireless = json_object_new_object();
+        json_object_object_add(wireless, "2gbus", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus")));
+        json_object_object_add(wireless, "2gbus24havg", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus24havg")));
+        json_object_object_add(wireless, "2gbus24hmax", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus24hmax")));
+        json_object_object_add(wireless, "2gbus24hmin", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus24hmin")));
+        json_object_object_add(wireless, "2gtotal24havg", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal24havg")));
+        json_object_object_add(wireless, "2gtotal24hmax", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal24hmax")));
+        json_object_object_add(wireless, "2gtotal24hmin", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal24hmin")));
+        json_object_object_add(wireless, "2gtx", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx")));
+        json_object_object_add(wireless, "2gtx24havg", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx24havg")));
+        json_object_object_add(wireless, "2gtx24hmax", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx24hmax")));
+        json_object_object_add(wireless, "2gtx24hmin", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx24hmin")));
+        json_object_object_add(wireless, "batif", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/batif")));
+
+        json_object_object_add(wireless, "batttvn", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/batttvn")));
+        json_object_object_add(wireless, "channel", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/channel")));
+        json_object_object_add(ret, "wireless", wireless);
+
        struct json_object *system = json_object_new_object();
        json_object_object_add(system, "site_code", get_site_code());
        json_object_object_add(ret, "system", system);

```
(obviously only 2.4ghz now)
(for those who quickly want to test it i added a example respondd - exchange it with /lib/gluon/respondd/respondd.so on your node)

if you want to use this patch in your Makefile .. this hints may help
```
# given that you have a file 0001-respondd.patch
gluon/patches/packages/gluon-respondd/0001-respondd.patch: 0001-respondd.patch gluon/.git
        mkdir -p gluon/patches/packages/gluon-respondd/
        cp $< gluon/patches/packages/gluon-respondd/
# dont forget to add similar to site.conf site.mk and so on ...
# gluon/patches/packages/gluon-respondd/0001-respondd.patch to all: statement
```

if you come so far, your nodes will spread the info : this looks like 
```
# gluon-neighbour-info -d ::1 -p 1001 -t 1 -c 1 -r nodeinfo
{"software":{"autoupdater":{"branch":"support","enabled":false},"batman-adv":{"version":"2013.4.0","compat":14},"fastd":{"version":"v18","enabled":true},"firmware":{"base":"gluon-v2016.1-165-ga852056","release":"v0000.externffgt"},"status-page":{"api":1}},"network":{"addresses":["fdf0:9bb:7814:a630:c66e:1fff:fe2d:4dee","2a03:2260:100e:23:c66e:1fff:fe2d:4dee","fe80::c66e:1fff:fe2d:4dee"],"mesh":{"bat0":{"interfaces":{"wireless":["f2:12:b5:a9:fd:7a"],"tunnel":["f2:12:b5:a9:fd:78"]}}},"mac":"c4:6e:1f:2d:4d:ee"},"owner":{"contact":"kaulquappen supäää"},"system":{"role":"node","site_code":"fffr"},"node_id":"c46e1f2d4dee","hostname":"fuzzle_solar","hardware":{"model":"TP-Link TL-WR841N\/ND v9","nproc":1},"wireless":{"act2":"4489951","bus2":"1287292"}}
```

The Patch for Meshviewer or Hopglass is also quiet simple (and should work on hopglass and meshviewer with slight corrections)
### deprecated ... explain new repsondd /airtime generated stuff soon (similar, but different and more indizes , see above)

```
# diff lib/infobox/node.js lib/infobox/node.js_bak 
155,168d154
<   function showAIRTIME2(d) {
<     var air2 = 1 / ( d.nodeinfo.wireless.act2 / d.nodeinfo.wireless.bus2 )
<     return function (el) {
<       el.appendChild(showBar("2400MhzTxRx", air2))
<       }
<     }
< 
<   function showAIRTIME5(d) {
<     var air5 = 1 / ( d.nodeinfo.wireless.act5 / d.nodeinfo.wireless.bus5 )
<     return function (el) {
<         el.appendChild(showBar("5000MhzTxRx", air5))
<         }
<     }
< 
226,235d211
< 
<     if (typeof d.nodeinfo.wireless !== "undefined") {
< 
<     if (d.nodeinfo.wireless.act2)
<       attributeEntry(attributes, "Airtime 2,4",  showAIRTIME2(d))
< 
<     if (d.nodeinfo.wireless.act5)
<       attributeEntry(attributes, "Airtime 5",  showAIRTIME5(d))
<   
```

remember: It is quite basic!

Create a file "modules" with the following content in your site directory:
```
GLUON_SITE_FEEDS="airtime"
PACKAGES_SSIDCHANGER_REPO=https://github.com/viisauksena/gluon-airtime.git
PACKAGES_SSIDCHANGER_COMMIT=abcdef0123456789....a100d6b067fc410068e7521d
PACKAGES_SSIDCHANGER_BRANCH=master
```
With this done you can add the package gluon-airtime to your site.mk

