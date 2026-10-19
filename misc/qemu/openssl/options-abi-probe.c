/* Native-header oracle for exported and macro SSL option APIs. */
#include <openssl/ssl.h>
#include <openssl/pem.h>
#include <openssl/x509v3.h>
#include <dlfcn.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr, "FAIL line %d: %s\n", __LINE__, #x); exit(1); } } while (0)
static void check_identity_certificate(const char *path) {
    FILE *file = fopen(path, "r");
    X509 *cert;
    GENERAL_NAMES *names;
    int i, dns = 0, ip = 0;
    CHECK(file != NULL);
    cert = PEM_read_X509(file, NULL, NULL, NULL); fclose(file);
    CHECK(cert != NULL);
    names = X509_get_ext_d2i(cert, NID_subject_alt_name, NULL, NULL);
    CHECK(names != NULL);
    for (i = 0; i < sk_GENERAL_NAME_num(names); ++i) {
        GENERAL_NAME *name = sk_GENERAL_NAME_value(names, i);
        int type = -1;
        ASN1_STRING *value = GENERAL_NAME_get0_value(name, &type);
        CHECK(type == name->type);
        CHECK(value == name->d.dNSName);
        CHECK(ASN1_STRING_length(value) == value->length);
        CHECK(ASN1_STRING_get0_data(value) == value->data);
        if (type == GEN_DNS) {
            const char *expected = dns == 0 ? "good.example" : "*.wild.example";
            CHECK(dns < 2);
            CHECK((size_t)value->length == strlen(expected));
            CHECK(memcmp(value->data, expected, value->length) == 0);
            printf("DNS %.*s\n", value->length, value->data); ++dns;
        } else if (type == GEN_IPADD) {
            CHECK(value->length == (ip == 0 ? 4 : 16));
            CHECK(value->data[value->length - 1] == 1); ++ip;
        }
    }
    CHECK(dns == 2 && ip == 2);
    CHECK(X509_check_host(cert, "good.example", 0, 0, NULL) == 1);
    CHECK(X509_check_host(cert, "cn-only.example", 0, 0, NULL) == 0);
    CHECK(X509_check_ip_asc(cert, "127.0.0.1", 0) == 1);
    CHECK(X509_check_ip_asc(cert, "::1", 0) == 1);
    GENERAL_NAMES_free(names); X509_free(cert);
    puts("PASS native SAN layout/accessors and certificate identity");
}
int main(int argc, char **argv) {
    SSL_CTX *ctx = SSL_CTX_new(TLS_client_method());
    SSL *ssl;
    const uint64_t mask = SSL_OP_NO_TICKET;
    const char *names[] = { "SSL_CTX_set_options", "SSL_CTX_clear_options", "SSL_CTX_get_options", "SSL_set_options", "SSL_clear_options", "SSL_get_options" };
    unsigned i;
    CHECK(ctx != NULL);
    ssl = SSL_new(ctx); CHECK(ssl != NULL);
    printf("long=%zu ulong=%zu version=%lx mask=%llx\n", sizeof(long), sizeof(unsigned long), OpenSSL_version_num(), (unsigned long long)mask);
    for (i = 0; i < 6; ++i) printf("%s exported=%d\n", names[i], dlsym(RTLD_DEFAULT, names[i]) != NULL);
    CHECK(((uint64_t)SSL_CTX_clear_options(ctx, mask) & mask) == 0);
    CHECK(((uint64_t)SSL_CTX_set_options(ctx, mask) & mask) == mask);
    CHECK(((uint64_t)SSL_CTX_get_options(ctx) & mask) == mask);
    CHECK(((uint64_t)SSL_CTX_clear_options(ctx, mask) & mask) == 0);
    CHECK(((uint64_t)SSL_CTX_get_options(ctx) & mask) == 0);
    CHECK(((uint64_t)SSL_clear_options(ssl, mask) & mask) == 0);
    CHECK(((uint64_t)SSL_set_options(ssl, mask) & mask) == mask);
    CHECK(((uint64_t)SSL_get_options(ssl) & mask) == mask);
    CHECK(((uint64_t)SSL_clear_options(ssl, mask) & mask) == 0);
    CHECK(((uint64_t)SSL_get_options(ssl) & mask) == 0);
#ifdef SSL_CTRL_CLEAR_OPTIONS
    if (!dlsym(RTLD_DEFAULT, "SSL_CTX_set_options")) {
        CHECK((unsigned long)SSL_CTX_set_options(ctx, mask) == (unsigned long)SSL_CTX_ctrl(ctx, SSL_CTRL_OPTIONS, mask, NULL));
        CHECK((unsigned long)SSL_CTX_get_options(ctx) == (unsigned long)SSL_CTX_ctrl(ctx, SSL_CTRL_OPTIONS, 0, NULL));
        CHECK((unsigned long)SSL_CTX_clear_options(ctx, mask) == (unsigned long)SSL_CTX_ctrl(ctx, SSL_CTRL_CLEAR_OPTIONS, mask, NULL));
        CHECK((unsigned long)SSL_set_options(ssl, mask) == (unsigned long)SSL_ctrl(ssl, SSL_CTRL_OPTIONS, mask, NULL));
        CHECK((unsigned long)SSL_get_options(ssl) == (unsigned long)SSL_ctrl(ssl, SSL_CTRL_OPTIONS, 0, NULL));
        CHECK((unsigned long)SSL_clear_options(ssl, mask) == (unsigned long)SSL_ctrl(ssl, SSL_CTRL_CLEAR_OPTIONS, mask, NULL));
    }
#endif
    printf("ASN1_STRING size=%zu length=%zu type=%zu data=%zu flags=%zu GENERAL_NAME size=%zu type=%zu d=%zu\n", sizeof(ASN1_STRING), offsetof(ASN1_STRING, length), offsetof(ASN1_STRING, type), offsetof(ASN1_STRING, data), offsetof(ASN1_STRING, flags), sizeof(GENERAL_NAME), offsetof(GENERAL_NAME, type), offsetof(GENERAL_NAME, d));
    printf("modern initializer=%d stack_num=%d stack_value=%d state=%s\n", dlsym(RTLD_DEFAULT, "OPENSSL_init_ssl") != NULL, dlsym(RTLD_DEFAULT, "OPENSSL_sk_num") != NULL, dlsym(RTLD_DEFAULT, "OPENSSL_sk_value") != NULL, SSL_state_string_long(ssl));
#ifdef SSL_CTRL_SET_MIN_PROTO_VERSION
    CHECK(SSL_CTX_set_min_proto_version(ctx, TLS1_1_VERSION) == 1);
    CHECK(SSL_CTX_get_min_proto_version(ctx) == TLS1_1_VERSION);
    CHECK(SSL_CTX_set_max_proto_version(ctx, TLS1_2_VERSION) == 1);
    CHECK(SSL_CTX_get_max_proto_version(ctx) == TLS1_2_VERSION);
#endif
    {
        const char *protocol_names[] = { "SSL_CTX_set_min_proto_version", "SSL_CTX_set_max_proto_version", "SSL_CTX_get_min_proto_version", "SSL_CTX_get_max_proto_version", "SSL_set_min_proto_version", "SSL_set_max_proto_version", "SSL_get_min_proto_version", "SSL_get_max_proto_version" };
        for (i = 0; i < 8; ++i) printf("%s exported=%d\n", protocol_names[i], dlsym(RTLD_DEFAULT, protocol_names[i]) != NULL);
        CHECK(SSL_CTX_set_min_proto_version(ctx, TLS1_1_VERSION) == 1);
        CHECK(SSL_CTX_set_max_proto_version(ctx, TLS1_2_VERSION) == 1);
        CHECK(SSL_CTX_get_min_proto_version(ctx) == TLS1_1_VERSION);
        CHECK(SSL_CTX_get_max_proto_version(ctx) == TLS1_2_VERSION);
        CHECK(SSL_set_min_proto_version(ssl, TLS1_1_VERSION) == 1);
        CHECK(SSL_set_max_proto_version(ssl, TLS1_2_VERSION) == 1);
        CHECK(SSL_get_min_proto_version(ssl) == TLS1_1_VERSION);
        CHECK(SSL_get_max_proto_version(ssl) == TLS1_2_VERSION);
        puts("PASS all eight native protocol-limit APIs");
    }
    if (argc > 1) check_identity_certificate(argv[1]);
    SSL_free(ssl); SSL_CTX_free(ctx);
    puts("PASS all six native-header option APIs");
    return 0;
}
