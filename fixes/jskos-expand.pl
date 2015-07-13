use v5.14.1;

# JSKOS mapping objects (experimenatal!)
# map plain URIs to objects with uri property

sub {
    my $item = shift;

    for my $bundle (grep { $_ } map { $item->{$_} } qw(from to)) {
        for (grep { ref $bundle->{$_} } qw(inScheme conceptSet conceptList)) {
            $bundle->{$_} = [
                map { ref $_ ? $_ : { uri => $_ } } @{$bundle->{$_}}
            ]
        }
    }

    $item;
}
