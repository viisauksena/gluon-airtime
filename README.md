Airtime script
============

collect Airtime - with newer Gluon respondd 

actually we reuse airtime basic script written for old gluon 2015.1 from announced from https://github.com/ffgtso/ffgt_packages-v2015.1/tree/master/gluon-airtime
and make a cronjob to gather data in /tmp folder, most important /tmp/act2 (which is active in seconds) and /tmp/bus2 (which is busy in seconds = rx and tx together) .. so with a little bit of math you can get averages .. maybe i will add a line to airtime script to get /tmp/air2avg

we do a little micron.d cronjob to run it often ...

now we need respondd to also collect these data, i have a running version - but this meant i had to compile it in the beginning, hope for other solutions .. otherwise we need a patch before we build actual firmware. The patch is quiet simple.
in gluon-respondd/src we add to the block **static struct json_object * respondd_provider_nodeinfo(void) {**
```c
        struct json_object *wireless = json_object_new_object();
        json_object_object_add(wireless, "act2", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/act2")));
        json_object_object_add(wireless, "bus2", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/bus2")));
        json_object_object_add(ret, "wireless", wireless);
```
(for those who quickly want to test it i added a example respondd - exchange it with /lib/gluon/respondd/respondd.so on your node)

if you come so far, your nodes will spread the info : this looks like 
```
# gluon-neighbour-info -d ::1 -p 1001 -t 1 -c 1 -r nodeinfo
{"software":{"autoupdater":{"branch":"support","enabled":false},"batman-adv":{"version":"2013.4.0","compat":14},"fastd":{"version":"v18","enabled":true},"firmware":{"base":"gluon-v2016.1-165-ga852056","release":"v0000.externffgt"},"status-page":{"api":1}},"network":{"addresses":["fdf0:9bb:7814:a630:c66e:1fff:fe2d:4dee","2a03:2260:100e:23:c66e:1fff:fe2d:4dee","fe80::c66e:1fff:fe2d:4dee"],"mesh":{"bat0":{"interfaces":{"wireless":["f2:12:b5:a9:fd:7a"],"tunnel":["f2:12:b5:a9:fd:78"]}}},"mac":"c4:6e:1f:2d:4d:ee"},"owner":{"contact":"kaulquappen supäää"},"system":{"role":"node","site_code":"fffr"},"node_id":"c46e1f2d4dee","hostname":"fuzzle_solar","hardware":{"model":"TP-Link TL-WR841N\/ND v9","nproc":1},"wireless":{"wireless_act":"5285166","wireless_bus":"1744874"}}
```

The Patch for Meshviewer or Hopglass is also quiet simple (and should work on hopglass and meshviewer with slight corrections)

```
# diff lib/infobox/node.js lib/infobox/node.js_bak 
155,174d154
<   function showAIRTIME2(d) {
<     if (!("airtime2" in d.nodeinfo.network.wireless))
<       return undefined
< 
<     return function (el) {
<       el.appendChild(showBar("Airtime2", d.nodeinfo.wireless.act2))
<       el.appendChild(showBar("Airtime2", d.nodeinfo.wireless.bus2))
<     }
<   }
< 
<   function showAIRTIME5(d) {
<     if (!("airtime5" in d.nodeinfo.network.wireless))
<       return undefined
< 
<     return function (el) {
<       el.appendChild(showBar("Airtime5", d.nodeinfo.wireless.act5))
<       el.appendChild(showBar("Airtime5", d.nodeinfo.wireless.bus5))
<     }
<   }
< 
232,245d211
<     if (typeof d.nodeinfo.network.wireless !== "undefined") {
<     if (d.nodeinfo.network.wireless)
<       attributeEntry(attributes, "Kanal 2,4 GHz",  dictGet(d.nodeinfo.network, ["wireless", "chan2"]))
< 
<     if (d.nodeinfo.network.wireless)
<       attributeEntry(attributes, "Kanal 5 GHz",  dictGet(d.nodeinfo.network, ["wireless", "chan5"]))
< 
<     if (d.nodeinfo.network.wireless)
<       attributeEntry(attributes, "Airtime 2,4",  showAIRTIME2(d))
< 
<     if (d.nodeinfo.network.wireless)
<       attributeEntry(attributes, "Airtime 5",  showAIRTIME5(d))
<     }
< 
```

remeber: It is quite basic!

Create a file "modules" with the following content in your site directory:

GLUON_SITE_FEEDS="airtime"<br>
PACKAGES_SSIDCHANGER_REPO=https://github.com/viisauksena/gluon-airtime.git<br>
PACKAGES_SSIDCHANGER_COMMIT=abcdef0123456789....a100d6b067fc410068e7521d<br>
PACKAGES_SSIDCHANGER_BRANCH=master<br>

With this done you can add the package gluon-airtime to your site.mk

