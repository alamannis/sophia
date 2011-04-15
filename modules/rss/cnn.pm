use strict;
use warnings;
use libmod::HTTPRequest;
use HTML::Strip;

sophia_module_add("rss.cnn", "1.0", \&init_rss_cnn, \&deinit_rss_cnn);

sub init_rss_cnn {
    sophia_command_add("rss.cnn:latest", \&cnn_latest_init, "Prints out CNN RSS feeds.", "");
    sophia_timer_add("cnn_latest_hook", \&cnn_latest_hook, 0);

    return 1;
}

sub deinit_rss_cnn {
    delete_sub "init_rss_cnn";
    delete_sub "cnn_latest_hook";
    sophia_command_del "rss.cnn:latest";
    delete_sub "deinit_rss_cnn";
}

my $CNN_LastDate = "test";
my @CNN_Channels = ("#divine-bots", "#main");

sub cnn_latest_init {
    my $objXML = loadXML("http://rss.cnn.com/rss/cnn_latest.rss");
    return unless $objXML;

    my @items = $objXML->findnodes("//item");
    return unless scalar(@items) > 0;

    my $count = 0;
    my ($desc, $link, $pubDate, $updatedPubDate);
    my @text;
    my $html = HTML::Strip->new;

    $updatedPubDate = $items[0]->find("./pubDate");
    $updatedPubDate = sprintf("%s", $updatedPubDate);
    return if ($updatedPubDate eq $CNN_LastDate);

    LINE: foreach my $item (@items) {
        $desc = sprintf("%s", $item->find("./description"));
        $desc = $html->parse($desc);
        $desc =~ s/\r\n|\n//g;
        $desc =~ s/\s+$//;
        
        $link = $item->find("./link");
        $pubDate = sprintf("%s", $item->find("./pubDate"));
        last LINE if ($pubDate eq $CNN_LastDate);

        @text = split /\&lt\;/, $desc;
        sophia_write(\@CNN_Channels, sprintf(POE::Component::IRC::Common::BOLD . 'CNN Latest:' . POE::Component::IRC::Common::BOLD . ' %s  Read more: %s', $desc, $link));
        
        last LINE if ($count++ == 2);
    }
    $html->eof;
    $CNN_LastDate = $updatedPubDate;
}

sub cnn_latest_hook {
    &cnn_latest_init;
    $_[KERNEL]->alarm( 'cnn_latest_hook' => time() + 60 * 5 );
}

1;
