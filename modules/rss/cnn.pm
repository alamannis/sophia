use strict;
use warnings;

sophia_module_add("rss.cnn", "1.0", \&init_rss_cnn, \&deinit_rss_cnn);

sub init_rss_cnn {
    if (!sophia_module_exists("rss.main")) {
        sophia_module_load("rss.main");
    }
    sophia_command_add("rss.cnn", \&rss_cnn_hook, "Displays CNN RSS feeds.", "");
    return 1;
}

sub deinit_rss_cnn {
    delete_sub "init_rss_cnn";
    delete_sub "rss_cnn_hook";
    sophia_command_del "rss.cnn";
    delete_sub "deinit_rss_cnn";
}

sub rss_cnn_hook {
}
