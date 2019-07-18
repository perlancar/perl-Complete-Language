package Complete::Language;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Complete::Common qw(:all);

our %SPEC;
use Exporter 'import';
our @EXPORT_OK = qw(complete_language_code);

$SPEC{complete_language_code} = {
    v => 1.1,
    summary => 'Complete from list of ISO-639 language codes',
    args => {
        word => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        variant => {
            schema => [str=>{in=>['alpha-2','alpha-3']}],
            default => 'alpha-2',
        },
    },
    result_naked => 1,
};
sub complete_language_code {
    require Complete::Util;

    state $codes = do {
        require Locale::Codes::Language_Codes;
        my $codes = {};
        my $id2names  = $Locale::Codes::Data{'language'}{'id2names'};
        my $id2alpha2 = $Locale::Codes::Data{'language'}{'id2code'}{'alpha-2'};
        my $id2alpha3 = $Locale::Codes::Data{'language'}{'id2code'}{'alpha-3'};

        for my $id (keys %$id2names) {
            if (my $c = $id2alpha2->{$id}) {
                $codes->{'alpha-2'}{$c} = $id2names->{$id}[0];
            }
            if (my $c = $id2alpha3->{$id}) {
                $codes->{'alpha-3'}{$c} = $id2names->{$id}[0];
            }
        }
        $codes;
    };

    my %args = @_;
    my $word = $args{word} // '';
    my $variant = $args{variant} // 'alpha-2';
    my $hash = $codes->{$variant};
    return [] unless $hash;

    Complete::Util::complete_hash_key(
        word  => $word,
        hash  => $hash,
        summaries_from_hash_values => 1,
    );
}

1;
#ABSTRACT:

=head1 SYNOPSIS

 use Complete::Language qw(complete_language_code);
 my $res = complete_language_code(word => 'V');
 # -> [qw/va vc ve vg vi vn vu/]

=cut
