[CCode(cheader_filename="pipewire/pipewire.h", cprefix = "pw_", lower_case_cprefix="pw_")]
namespace Pipewire {
    void init (int* argc = null, string** argv = null);
    void deinit ();
    string get_application_name ();
    string get_prgname ();
    string get_user_name ();
    string get_host_name ();
    string get_client_name ();
    bool in_valgrind ();
    bool check_option (string option, string value);
    SPADirection direction_reverse (SPADirection direction);
    int set_domain (string domain);
    string get_domain ();

    [CCode (cname = "enum spa_direction", has_type_id = false, cprefix = "SPA_DIRECTION_")]
    public enum SPADirection {
        INPUT,
        OUTPUT
    }


    [CCode (cprefix = "pw_debug_")]
    namespace Debug {
        bool is_category_enabled (string name);
    }
}
