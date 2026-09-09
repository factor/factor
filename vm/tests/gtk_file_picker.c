#include <stdio.h>
#include <string.h>
#include <unistd.h>

extern int gtk_init_check(int *, char ***);
extern void *gtk_file_chooser_dialog_new(const char *, void *, int, const char *, ...);
extern int gtk_file_chooser_get_action(void *);
extern void gtk_file_chooser_set_current_name(void *, const char *);
extern int gtk_file_chooser_set_current_folder(void *, const char *);
extern char *gtk_file_chooser_get_filename(void *);
extern int g_main_context_iteration(void *, int);
extern void gtk_widget_destroy(void *);
extern void g_free(void *);

int main(void) {
    if (!gtk_init_check(NULL, NULL)) return 1;
    void *save = gtk_file_chooser_dialog_new("Save File", NULL, 1,
        "Cancel", -6, "Save", -3, NULL);
    if (!save || gtk_file_chooser_get_action(save) != 1) return 1;
    if (!gtk_file_chooser_set_current_folder(save, "/tmp")) return 1;
    gtk_file_chooser_set_current_name(save, "nonexistent-new-file.txt");
    char *name = NULL;
    for (int i = 0; i < 500 && !name; ++i) {
        g_main_context_iteration(NULL, 0);
        name = gtk_file_chooser_get_filename(save);
        if (!name) usleep(10000);
    }
    if (!name || strcmp(name, "/tmp/nonexistent-new-file.txt")) return 1;
    g_free(name);
    gtk_widget_destroy(save);
    void *open = gtk_file_chooser_dialog_new("Open File", NULL, 0,
        "Cancel", -6, "Open", -3, NULL);
    if (!open || gtk_file_chooser_get_action(open) != 0) return 1;
    gtk_widget_destroy(open);
    puts("C-CONTROL GTK open/save actions and new filename passed");
    return 0;
}
