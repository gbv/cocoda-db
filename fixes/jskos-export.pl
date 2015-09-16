use v5.14.1;

sub {
    my $item = shift;
    delete $item->{_id};
    $item->{'@context'} = "http://gbv.github.io/jskos/context.json";
    $item;
}
