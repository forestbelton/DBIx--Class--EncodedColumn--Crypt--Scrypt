use strict;
use warnings;

# ABSTRACT: scrypt support for DBIx::Class::EncodedColumn
package DBIx::Class::EncodedColumn::Crypt::Scrypt;

use Encode qw(is_utf8 encode_utf8);
use Crypt::ScryptKDF 0.008 qw(scrypt_hash scrypt_hash_verify
    random_bytes);

sub make_encode_sub {
    my ($class, $col, $args) = @_;

    $args->{cost}     //= 8;
    $args->{blocksz}  //= 8;
    $args->{parallel} //= 1;
    $args->{saltsz}   //= 32;
    $args->{keysz}    //= 32;

    sub {
        my ($text) = @_;
        $text = encode_utf8($text) if is_utf8($text);
        scrypt_hash(
            $text,
            random_bytes($args->{saltsz}),
            $args->{cost},
            $args->{blocksz},
            $args->{parallel},
            $args->{keysz});
    };
}

sub make_check_sub {
    my ($class, $col) = @_;

    sub {
        my ($result, $pass) = @_;
        $pass = encode_utf8($pass) if is_utf8($pass);
        scrypt_hash_verify($pass, $result->get_column($col));
    };
}

1;
