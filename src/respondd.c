#include <respondd.h>

#include <json-c/json.h>
#include <libgluonutil.h>
#include <libplatforminfo.h>

#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <sys/utsname.h>
#include <sys/vfs.h>



static struct json_object * respondd_provider_nodeinfo(void) {
        struct json_object *ret = json_object_new_object();

        struct json_object *wireless = json_object_new_object();
        json_object_object_add(wireless, "2gbus", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus")));
        json_object_object_add(wireless, "2gbus24havg", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus24havg")));
        json_object_object_add(wireless, "2gbus24hmax", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus24hmax")));
        json_object_object_add(wireless, "2gbus24hmin", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gbus24hmin")));

        json_object_object_add(wireless, "2gtotal", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal")));
        json_object_object_add(wireless, "2gtotal24havg", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal24havg")));
        json_object_object_add(wireless, "2gtotal24hmax", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal24hmax")));
        json_object_object_add(wireless, "2gtotal24hmin", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtotal24hmin")));

        json_object_object_add(wireless, "2gtx", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx")));
        json_object_object_add(wireless, "2gtx24havg", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx24havg")));
        json_object_object_add(wireless, "2gtx24hmax", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx24hmax")));
        json_object_object_add(wireless, "2gtx24hmin", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/2gtx24hmin")));

        json_object_object_add(wireless, "batif", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/batif")));
        json_object_object_add(wireless, "batttvn", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/batttvn")));
        json_object_object_add(wireless, "channel", gluonutil_wrap_and_free_string(gluonutil_read_line("/tmp/xtra/channel")));

        json_object_object_add(ret, "wireless", wireless);

        return ret;
}


const struct respondd_provider_info respondd_providers[] = {
	{"nodeinfo", respondd_provider_nodeinfo},
	{}
};
