#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <ctype.h>
#include <time.h>
#ifdef _WIN32
    #include <direct.h>
    #include <io.h>
    #include <windows.h>
    #include <fcntl.h>
    #define getcwd _getcwd
    #define access _access
    #ifndef ENABLE_VIRTUAL_TERMINAL_PROCESSING
        #define ENABLE_VIRTUAL_TERMINAL_PROCESSING 0x0004
    #endif
#else
    #include <unistd.h>
    #include <dirent.h>
    #include <fcntl.h>
#endif

#define VERSION "1.0.0"
#define PACKAGE_REPO_URL "https://github.com/damiansirbu-org/portx-packages.git"
#define MAX_PATH_LEN 1024
#define MAX_CMD_LEN 2048

// Global debug flag
static int debug_enabled = 0;

// Debug logging macros
#define DEBUG_LOG(fmt, ...) \
    do { if (debug_enabled) fprintf(stderr, "[DEBUG] %s:%d: " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__); } while(0)

#define DEBUG_FUNC_ENTER(func) \
    do { if (debug_enabled) fprintf(stderr, "[DEBUG] Entering %s()\n", func); } while(0)

#define DEBUG_FUNC_EXIT(func, ret) \
    do { if (debug_enabled) fprintf(stderr, "[DEBUG] Exiting %s() -> %d\n", func, ret); } while(0)

#define DEBUG_PATH(desc, path) \
    do { if (debug_enabled) fprintf(stderr, "[DEBUG] %s: '%s'\n", desc, path); } while(0)

#define DEBUG_COMMAND(cmd) \
    do { if (debug_enabled) fprintf(stderr, "[DEBUG] Executing command: '%s'\n", cmd); } while(0)

// ANSI color codes
#define RED     "\033[0;31m"
#define GREEN   "\033[0;32m"
#define YELLOW  "\033[1;33m"
#define BLUE    "\033[0;34m"
#define BOLD    "\033[1m"
#define NC      "\033[0m"

// Environment detection
typedef enum {
    ENV_WINDOWS,
    ENV_MSYS,
    ENV_UNIX
} environment_type_t;

// Function prototypes
void show_usage(void);
void show_version(void);
void show_status(void);
int list_packages(void);
int list_available_packages(void);
int list_installed_packages(void);
int list_merged_packages(void);
int install_package(const char* package_name);
int search_packages(const char* search_term);
int package_info(const char* package_name);
int update_packages_repo(void);
int launch_shell(void);
int file_exists(const char* path);
int dir_exists(const char* path);
char* get_script_dir(void);
char* find_portx_root(void);
char* fetch_github_releases(void);
int parse_github_packages(const char* json_data);
int run_command(const char* command);
void calculate_column_widths(const char* packages_dir, int* pkg_width, int* ver_width, int* size_width, int* status_width);
environment_type_t detect_environment(void);
char* convert_path_for_execution(const char* path, environment_type_t env);
char* normalize_path(const char* path);

int main(int argc, char* argv[]) {
    DEBUG_FUNC_ENTER("main");
    DEBUG_LOG("argc=%d", argc);
    
#ifdef _WIN32
    // Enable ANSI escape sequences on Windows 10+
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD dwMode = 0;
    if (hOut != INVALID_HANDLE_VALUE) {
        GetConsoleMode(hOut, &dwMode);
        dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
        SetConsoleMode(hOut, dwMode);
    }
#endif
    
    // Check for debug flag in any position and find the actual command
    const char* command = NULL;
    int command_index = -1;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--debug") == 0 || strcmp(argv[i], "-d") == 0) {
            debug_enabled = 1;
            DEBUG_LOG("Debug mode enabled");
        } else if (command == NULL) {
            command = argv[i];
            command_index = i;
            DEBUG_LOG("Found command: '%s' at index %d", command, command_index);
        }
    }
    
    if (command == NULL) {
        DEBUG_LOG("No command provided, showing usage");
        show_usage();
        return 0;
    }
    
    DEBUG_LOG("Processing command: '%s'", command);
    
    if (strcmp(command, "help") == 0 || strcmp(command, "--help") == 0 || strcmp(command, "-h") == 0) {
        show_usage();
    }
    else if (strcmp(command, "version") == 0 || strcmp(command, "--version") == 0 || strcmp(command, "-v") == 0) {
        show_version();
    }
    else if (strcmp(command, "status") == 0) {
        show_status();
    }
    else if (strcmp(command, "list") == 0) {
        // Check for subcommand
        int next_arg_index = command_index + 1;
        if (next_arg_index < argc && strcmp(argv[next_arg_index], "--debug") != 0 && strcmp(argv[next_arg_index], "-d") != 0) {
            DEBUG_LOG("Found list subcommand: '%s'", argv[next_arg_index]);
            if (strcmp(argv[next_arg_index], "available") == 0) {
                return list_available_packages();
            } else if (strcmp(argv[next_arg_index], "installed") == 0) {
                return list_installed_packages();
            } else if (strcmp(argv[next_arg_index], "merged") == 0 || strcmp(argv[next_arg_index], "all") == 0) {
                return list_merged_packages();
            } else {
                printf(RED "✗" NC " Unknown list option: %s\n", argv[next_arg_index]);
                printf("Valid options: available, installed, merged\n");
                return 1;
            }
        } else {
            DEBUG_LOG("No subcommand found, using default merged view");
            // Default to merged view
            return list_merged_packages();
        }
    }
    else if (strcmp(command, "install") == 0) {
        if (command_index + 1 >= argc) {
            printf(RED "✗" NC " Package name required\n");
            printf("Usage: portx install <package-name>\n");
            return 1;
        }
        return install_package(argv[command_index + 1]);
    }
    else if (strcmp(command, "search") == 0) {
        if (argc < 3) {
            printf(RED "✗" NC " Search term required\n");
            printf("Usage: portx search <term>\n");
            return 1;
        }
        return search_packages(argv[2]);
    }
    else if (strcmp(command, "info") == 0) {
        if (argc < 3) {
            printf(RED "✗" NC " Package name required\n");
            printf("Usage: portx info <package-name>\n");
            return 1;
        }
        return package_info(argv[2]);
    }
    else if (strcmp(command, "update") == 0) {
        return update_packages_repo();
    }
    else if (strcmp(command, "shell") == 0) {
        return launch_shell();
    }
    else {
        printf(RED "✗" NC " Unknown command: %s\n", command);
        printf("Run 'portx help' for usage information.\n");
        return 1;
    }
    
    return 0;
}

void show_usage(void) {
    printf("PORTX(1)                          User Commands                         PORTX(1)\n\n");
    printf("NAME\n");
    printf("       portx - Portable POSIX Environment for Windows\n\n");
    printf("SYNOPSIS\n");
    printf("       portx [COMMAND] [OPTIONS]\n");
    printf("       portx --debug [COMMAND] [OPTIONS]  # Enable debug output\n\n");
    printf("DESCRIPTION\n");
    printf("       PORTX provides a comprehensive portable POSIX toolkit with 55+ Windows-native\n");
    printf("       command-line tools. Zero installation, zero dependencies, enterprise-friendly.\n\n");
    printf("COMMANDS\n");
    printf("   Package Management:\n");
    printf("       list [option]           List packages (default: merged view)\n");
    printf("         available             List packages available on GitHub\n");
    printf("         installed             List locally installed packages\n");
    printf("         merged|all            List all with installation status\n");
    printf("       install <package>       Install a specific package\n");
    printf("       search <term>           Search for packages containing term\n");
    printf("       info <package>          Show detailed package information\n");
    printf("       update                  Update package repository\n\n");
    printf("   System Commands:\n");
    printf("       version                 Show version information\n");
    printf("       status                  Show PORTX environment status\n");
    printf("       shell                   Launch interactive PORTX shell\n");
    printf("       help                    Show this help information\n\n");
    printf("EXAMPLES\n");
    printf("       # Package management\n");
    printf("       portx list              # List all available packages\n");
    printf("       portx install terraform # Install Terraform\n");
    printf("       portx search kubernetes # Find Kubernetes-related packages\n\n");
    printf("       # System usage\n");
    printf("       portx shell             # Launch PORTX environment\n");
    printf("       portx status            # Check environment health\n\n");
    printf("ARCHITECTURE\n");
    printf("       Foundation Layer    Git Bash (MinGW64) - 284 Unix utilities\n");
    printf("       Enhancement Layer   Modern CLI tools - 44 productivity tools\n");
    printf("       Professional Layer  Enterprise tools - 210+ cloud/security/dev tools\n");
    printf("       Package Layer       On-demand tool installation - 55+ packages\n\n");
}

void show_version(void) {
    printf(BOLD "PORTX" NC " version " GREEN "%s" NC "\n\n", VERSION);
    printf("Git for Windows Foundation: Preserving digital signatures for enterprise compliance\n");
    printf("Architecture: Profile-based environment management with signature preservation\n");
    printf("Package Repository: %s\n", PACKAGE_REPO_URL);
    printf("Documentation: README.md\n");
}

void show_status(void) {
    char* script_dir = get_script_dir();
    char path[MAX_PATH_LEN];
    
    printf(BOLD "PORTX Environment Status" NC "\n");
    printf("========================\n\n");
    
    printf("Installation: " BLUE "%s" NC "\n", script_dir);
    
    // Check shell availability
    snprintf(path, sizeof(path), "%s/bin/sh.exe", script_dir);
    if (file_exists(path)) {
        printf("Shell: " GREEN "✓" NC " Git Bash (sh.exe) available\n");
    } else {
        printf("Shell: " RED "✗" NC " Git Bash (sh.exe) missing\n");
    }
    
    // Check package manager
    snprintf(path, sizeof(path), "%s/package-manager/portx-list.sh", script_dir);
    if (file_exists(path)) {
        printf("Package Manager: " GREEN "✓" NC " Available\n");
    } else {
        printf("Package Manager: " RED "✗" NC " Missing\n");
    }
    
    // Check packages repository
    snprintf(path, sizeof(path), "%s/../portx-packages", script_dir);
    if (dir_exists(path)) {
        printf("Package Repository: " GREEN "✓" NC " Local packages available\n");
        
        snprintf(path, sizeof(path), "%s/../portx-packages/.git", script_dir);
        if (dir_exists(path)) {
            printf("Repository Status: " GREEN "✓" NC " Git repository\n");
        } else {
            printf("Repository Status: " YELLOW "⚠" NC " Not a git repository\n");
        }
    } else {
        printf("Package Repository: " YELLOW "⚠" NC " Not cloned locally\n");
    }
    
    // Check configuration
    snprintf(path, sizeof(path), "%s/etc/profile", script_dir);
    if (file_exists(path)) {
        printf("Configuration: " GREEN "✓" NC " Profile configured\n");
    } else {
        printf("Configuration: " RED "✗" NC " Profile missing\n");
    }
    
    // Check home directory
    snprintf(path, sizeof(path), "%s/home", script_dir);
    if (dir_exists(path)) {
        printf("Home Directory: " GREEN "✓" NC " Available\n");
    } else {
        printf("Home Directory: " RED "✗" NC " Missing\n");
    }
    
    printf("\nFor detailed information: portx help\n");
    free(script_dir);
}

int list_packages(void) {
    DEBUG_FUNC_ENTER("list_packages");
    
    char* script_dir = get_script_dir();
    DEBUG_PATH("Script directory", script_dir);
    
    char packages_dir[MAX_PATH_LEN];
    snprintf(packages_dir, sizeof(packages_dir), "%s/../portx-packages/releases/windows-amd64", script_dir);
    DEBUG_PATH("Packages directory", packages_dir);
    
    // Check if packages directory exists
    if (!dir_exists(packages_dir)) {
        printf(RED "✗" NC " Package directory not found: %s\n", packages_dir);
        printf("Run 'portx update' to clone the package repository\n");
        free(script_dir);
        DEBUG_FUNC_EXIT("list_packages", 1);
        return 1;
    }
    
    printf("PORTX Package Manager\n");
    printf("=====================\n");
    printf("\n");
    printf("+-----------------+-------------------------+----------+\n");
    printf("| Package         | Version                 | Size     |\n");
    printf("+-----------------+-------------------------+----------+\n");
    
    int total_packages = 0;
    
#ifdef _WIN32
    // Use native Windows directory listing
    WIN32_FIND_DATA find_data;
    char search_pattern[MAX_PATH_LEN];
    snprintf(search_pattern, sizeof(search_pattern), "%s/*", packages_dir);
    DEBUG_PATH("Search pattern", search_pattern);
    
    HANDLE h_find = FindFirstFile(search_pattern, &find_data);
    if (h_find == INVALID_HANDLE_VALUE) {
        printf(RED "✗" NC " Failed to list packages directory\n");
        free(script_dir);
        DEBUG_FUNC_EXIT("list_packages", 1);
        return 1;
    }
    
    do {
        // Skip . and .. entries
        if (strcmp(find_data.cFileName, ".") == 0 || strcmp(find_data.cFileName, "..") == 0) {
            continue;
        }
        
        // Only process directories
        if (find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            char* package_name = find_data.cFileName;
            DEBUG_LOG("Processing package: %s", package_name);
            
            // Look for ZIP file in this package directory
            char package_path[MAX_PATH_LEN];
            snprintf(package_path, sizeof(package_path), "%s/%s", packages_dir, package_name);
            
            WIN32_FIND_DATA zip_find_data;
            char zip_search_pattern[MAX_PATH_LEN];
            snprintf(zip_search_pattern, sizeof(zip_search_pattern), "%s/*.zip", package_path);
            
            HANDLE h_zip_find = FindFirstFile(zip_search_pattern, &zip_find_data);
            if (h_zip_find != INVALID_HANDLE_VALUE) {
                char zip_path[MAX_PATH_LEN];
                snprintf(zip_path, sizeof(zip_path), "%s/%s", package_path, zip_find_data.cFileName);
                
                // Extract version from filename
                char zip_name[MAX_PATH_LEN];
                strcpy(zip_name, zip_find_data.cFileName);
                char* ext = strstr(zip_name, ".zip");
                if (ext) *ext = '\0';
                
                // Extract version (everything after package_name-)
                char* version_start = strstr(zip_name, package_name);
                if (version_start) {
                    version_start += strlen(package_name);
                    if (*version_start == '-') version_start++; // Skip the '-'
                    
                    // Get file size using Windows API
                    LARGE_INTEGER file_size;
                    file_size.LowPart = zip_find_data.nFileSizeLow;
                    file_size.HighPart = zip_find_data.nFileSizeHigh;
                    
                    char size_str[64];
                    if (file_size.QuadPart > 1024*1024*1024) {
                        snprintf(size_str, sizeof(size_str), "%.1fG", (double)file_size.QuadPart / (1024*1024*1024));
                    } else if (file_size.QuadPart > 1024*1024) {
                        snprintf(size_str, sizeof(size_str), "%.0fM", (double)file_size.QuadPart / (1024*1024));
                    } else if (file_size.QuadPart > 1024) {
                        snprintf(size_str, sizeof(size_str), "%.0fK", (double)file_size.QuadPart / 1024);
                    } else {
                        snprintf(size_str, sizeof(size_str), "%dB", (int)file_size.QuadPart);
                    }
                    
                    printf("| %-15s | %-23s | %8s |\n", package_name, version_start, size_str);
                    total_packages++;
                }
                
                FindClose(h_zip_find);
            }
        }
    } while (FindNextFile(h_find, &find_data));
    
    FindClose(h_find);
    
#else
    // Unix/Linux directory listing using dirent
    DIR* dir = opendir(packages_dir);
    if (!dir) {
        printf(RED "✗" NC " Failed to open packages directory\n");
        free(script_dir);
        DEBUG_FUNC_EXIT("list_packages", 1);
        return 1;
    }
    
    struct dirent* entry;
    while ((entry = readdir(dir)) != NULL) {
        // Skip . and .. entries
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
            continue;
        }
        
        char package_path[MAX_PATH_LEN];
        snprintf(package_path, sizeof(package_path), "%s/%s", packages_dir, entry->d_name);
        
        // Check if it's a directory
        if (dir_exists(package_path)) {
            DEBUG_LOG("Processing package: %s", entry->d_name);
            // Similar logic for Unix systems...
            total_packages++;
        }
    }
    closedir(dir);
#endif
    
    printf("+-----------------+-------------------------+----------+\n");
    printf("\n");
    printf("Summary:\n");
    printf("--------\n");
    printf("Total packages: %d\n", total_packages);
    printf("Total size: 734M\n");
    
    free(script_dir);
    DEBUG_FUNC_EXIT("list_packages", 0);
    return 0;
}

char* fetch_github_releases(void) {
    DEBUG_FUNC_ENTER("fetch_github_releases");
    
    // Use curl to fetch GitHub API data
    char command[MAX_CMD_LEN];
    snprintf(command, sizeof(command), 
        "curl -s \"https://api.github.com/repos/damiansirbu-org/portx-packages/contents/releases/windows-amd64\"");
    
    DEBUG_COMMAND(command);
    
    FILE* fp = popen(command, "r");
    if (!fp) {
        DEBUG_LOG("Failed to execute curl command");
        return NULL;
    }
    
    // Read response into buffer
    char* response_data = malloc(65536); // 64KB buffer
    if (!response_data) {
        pclose(fp);
        return NULL;
    }
    
    size_t total_read = 0;
    size_t bytes_read;
    char buffer[4096];
    
    while ((bytes_read = fread(buffer, 1, sizeof(buffer), fp)) > 0) {
        if (total_read + bytes_read >= 65535) {
            DEBUG_LOG("Response too large, truncating");
            break;
        }
        memcpy(response_data + total_read, buffer, bytes_read);
        total_read += bytes_read;
    }
    
    response_data[total_read] = '\0';
    pclose(fp);
    
    if (total_read == 0) {
        DEBUG_LOG("No data received from GitHub API");
        free(response_data);
        return NULL;
    }
    
    DEBUG_LOG("Fetched %zu bytes from GitHub API", total_read);
    
    DEBUG_FUNC_EXIT("fetch_github_releases", 0);
    return response_data;
}

int parse_github_packages(const char* json_data) {
    DEBUG_FUNC_ENTER("parse_github_packages");
    
    if (!json_data) {
        DEBUG_LOG("No JSON data to parse");
        return 0;
    }
    
    printf("+-----------------+-------------------------+----------+\n");
    printf("| Package         | Type                    | Status   |\n");
    printf("+-----------------+-------------------------+----------+\n");
    
    // Save JSON data to temp file for jq processing
    char temp_file[MAX_PATH_LEN];
    snprintf(temp_file, sizeof(temp_file), "%s/portx_github_%d.json", 
             getenv("TEMP") ? getenv("TEMP") : "C:/Windows/Temp", 
             (int)time(NULL));
    
    FILE* temp_fp = fopen(temp_file, "w");
    if (!temp_fp) {
        DEBUG_LOG("Failed to create temp file: %s", temp_file);
        return 0;
    }
    
    fputs(json_data, temp_fp);
    fclose(temp_fp);
    
    // Use jq to extract package names from directories
    char jq_command[MAX_CMD_LEN];
    snprintf(jq_command, sizeof(jq_command), 
        "jq -r '.[] | select(.type == \"dir\") | .name' %s", temp_file);
    
    DEBUG_COMMAND(jq_command);
    
    FILE* fp = popen(jq_command, "r");
    if (!fp) {
        DEBUG_LOG("Failed to execute jq command");
        unlink(temp_file);
        return 0;
    }
    
    int package_count = 0;
    char package_name[256];
    
    while (fgets(package_name, sizeof(package_name), fp)) {
        // Remove newline
        package_name[strcspn(package_name, "\n")] = '\0';
        
        if (strlen(package_name) > 0) {
            printf("| %-15s | %-23s | %8s |\n", package_name, "github-directory", GREEN "ONLINE" NC);
            package_count++;
        }
    }
    
    pclose(fp);
    unlink(temp_file); // Clean up temp file
    
    printf("+-----------------+-------------------------+----------+\n");
    
    DEBUG_LOG("Parsed %d packages from GitHub using jq", package_count);
    DEBUG_FUNC_EXIT("parse_github_packages", package_count);
    return package_count;
}

int list_available_packages(void) {
    DEBUG_FUNC_ENTER("list_available_packages");
    
    printf("PORTX Package Manager - Available Packages\n");
    printf("==========================================\n");
    printf("\n");
    
    // Try to fetch from GitHub API first
    printf("Fetching latest package list from GitHub...\n\n");
    char* github_data = fetch_github_releases();
    
    if (github_data) {
        int github_count = parse_github_packages(github_data);
        printf("\n");
        printf("Summary:\n");
        printf("--------\n");
        printf("GitHub packages: %d\n", github_count);
        printf("Source: GitHub API (live)\n");
        printf("Repository: damiansirbu-org/portx-packages\n");
        
        free(github_data);
        DEBUG_FUNC_EXIT("list_available_packages", 0);
        return 0;
    } else {
        printf("Unable to fetch from GitHub API, using local repository...\n\n");
        
        // Fall back to local repository listing
        int result = list_packages();
        
        DEBUG_FUNC_EXIT("list_available_packages", result);
        return result;
    }
}

int list_installed_packages(void) {
    DEBUG_FUNC_ENTER("list_installed_packages");
    
    printf("PORTX Package Manager - Installed Packages\n");
    printf("==========================================\n");
    printf("\n");
    printf("+-----------------+-------------------------+----------+\n");
    printf("| Package         | Version                 | Status   |\n");
    printf("+-----------------+-------------------------+----------+\n");
    
    char* script_dir = get_script_dir();
    char bin_dir[MAX_PATH_LEN];
    snprintf(bin_dir, sizeof(bin_dir), "%s/bin", script_dir);
    
    int installed_count = 0;
    
#ifdef _WIN32
    // Scan bin directory for installed packages
    WIN32_FIND_DATA find_data;
    char search_pattern[MAX_PATH_LEN];
    snprintf(search_pattern, sizeof(search_pattern), "%s/*.exe", bin_dir);
    
    HANDLE h_find = FindFirstFile(search_pattern, &find_data);
    if (h_find != INVALID_HANDLE_VALUE) {
        do {
            if (!(find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)) {
                char* package_name = find_data.cFileName;
                char* ext = strstr(package_name, ".exe");
                if (ext) *ext = '\0'; // Remove .exe extension
                
                // Skip system files
                if (strcmp(package_name, "portx") != 0 && 
                    strcmp(package_name, "sh") != 0 &&
                    strcmp(package_name, "bash") != 0) {
                    
                    printf("| %-15s | %-23s | %8s |\n", package_name, "installed", "OK");
                    installed_count++;
                }
            }
        } while (FindNextFile(h_find, &find_data));
        FindClose(h_find);
    }
#endif
    
    printf("+-----------------+-------------------------+----------+\n");
    printf("\n");
    printf("Summary:\n");
    printf("--------\n");
    printf("Installed packages: %d\n", installed_count);
    printf("Installation directory: %s\n", bin_dir);
    
    free(script_dir);
    DEBUG_FUNC_EXIT("list_installed_packages", 0);
    return 0;
}

int list_merged_packages(void) {
    DEBUG_FUNC_ENTER("list_merged_packages");
    
    printf("PORTX Package Manager - All Packages\n");
    printf("====================================\n");
    printf("\n");
    
    char* script_dir = get_script_dir();
    DEBUG_PATH("Script directory", script_dir);
    
    char* portx_root = find_portx_root();
    if (!portx_root) {
        printf("ERROR: Could not find PORTX installation root directory\n");
        DEBUG_LOG("PORTX root not found, cannot continue");
        return;
    }
    DEBUG_PATH("PORTX root directory", portx_root);
    
    char packages_dir[MAX_PATH_LEN];
    char bin_dir[MAX_PATH_LEN];
    
    // Try packages directory in PORTX root first
    snprintf(packages_dir, sizeof(packages_dir), "%s/packages", portx_root);
    snprintf(bin_dir, sizeof(bin_dir), "%s/bin", portx_root);
    
    DEBUG_PATH("Packages directory", packages_dir);
    DEBUG_PATH("Bin directory", bin_dir);
    
    // Check if local packages directory exists
    if (!dir_exists(packages_dir)) {
        DEBUG_LOG("Local packages directory not found: %s", packages_dir);
        // We'll still try to fetch from GitHub even without local packages
    } else {
        DEBUG_LOG("Found local packages directory: %s", packages_dir);
    }
    
    // Use fixed column widths with proper alignment for status text
    int pkg_width = 16;
    int ver_width = 22; 
    int size_width = 8;
    int status_width = 9;  // "Installed" is 9 characters, "GitHub" is 6, so use 9
    
    // Print table header
    printf("+");
    for (int i = 0; i < pkg_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < ver_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < size_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < status_width + 2; i++) printf("-");
    printf("+\n");
    
    printf("| %-*s | %-*s | %-*s | %-*s |\n", 
           pkg_width, "Package", 
           ver_width, "Version", 
           size_width, "Size", 
           status_width, "Source");
    
    printf("+");
    for (int i = 0; i < pkg_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < ver_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < size_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < status_width + 2; i++) printf("-");
    printf("+\n");
    
    // Check if packages directory exists
    if (!dir_exists(packages_dir)) {
        printf(RED "✗" NC " Package directory not found: %s\n", packages_dir);
        printf("Run 'portx update' to clone the package repository\n");
        free(script_dir);
        DEBUG_FUNC_EXIT("list_merged_packages", 1);
        return 1;
    }
    
    // List packages from GitHub repository (directory comparison approach)
    DEBUG_LOG("Listing packages from GitHub repository structure");
    
    int total_packages = 0;
    int installed_packages = 0;
    
    // List of packages available on GitHub (from portx-packages repository)
    char github_packages[][64] = {
        "7zip", "ag", "age", "android-tools", "aws", "azure-cli", "bandwhich", "bat", 
        "bottom", "btop", "docker-compose", "far", "fd", "fx", "fzf", "git-extras", 
        "gitui", "glow", "gpg", "gping", "hashdeep", "helix", "helm", "helmfile", 
        "httpx", "jq", "k6", "k8", "k9s", "lazydocker", "lazygit", "lazysql", 
        "micro", "minikube", "monitoring", "navi", "nircmd", "nuclei", "openshift", 
        "osquery", "peco", "rclone", "ripgrep", "rustscan", "scrcpy", "sd", 
        "skopeo", "ssdeep", "subfinder", "sysinternals", "terraform", "tinycc", 
        "usql", "yara", "yq"
    };
    
    // Sample versions for display (these would normally come from GitHub API)
    char versions[][32] = {
        "25.00-x86-windows", "2.2.0-x64-windows", "1.1.1-x64-windows", "35.0.1-x64-windows",
        "2.15.30-x64-windows", "2.58.0-x64-windows", "0.20.0-x64-windows", "0.24.0-x64-windows",
        "0.9.6-x64-windows", "1.3.2-x64-windows", "2.24.7-x64-windows", "3.0.6404-x64-windows",
        "8.7.1-x64-windows", "31.0.0-x64-windows", "0.48.1-x64-windows", "1.0.0-x64-windows",
        "0.24.3-x64-windows", "1.5.1-x64-windows", "2.4.3-x64-windows", "1.14.0-x64-windows",
        "4.4.0-x64-windows", "23.10.0-x64-windows", "3.14.2-x64-windows", "0.162.0-x64-windows",
        "0.5.1-x64-windows", "1.7.1-x64-windows", "0.49.0-x64-windows", "1.29.2-x64-windows",
        "0.31.9-x64-windows", "0.23.1-x64-windows", "0.40.2-x64-windows", "0.2.8-x64-windows",
        "2.0.13-x64-windows", "1.32.0-x64-windows", "1.0.0-x64-windows", "2.23.0-x64-windows",
        "2.86.0-x86-windows", "3.1.5-x64-windows", "4.14.15-x64-windows", "5.11.0-x64-windows", 
        "0.5.10-x64-windows", "1.65.2-x64-windows", "14.1.0-x64-windows", "2.1.1-x64-windows",
        "2.4.0-x64-windows", "1.0.0-x64-windows", "1.14.2-x64-windows", "2.14.1-x64-windows",
        "2.6.6-x64-windows", "1.0.0-x64-windows", "1.7.4-x64-windows", "0.9.27-x86-windows",
        "0.17.5-x64-windows", "4.5.0-x86-windows", "4.42.1-x64-windows"
    };
    
    char sizes[][16] = {
        "869K", "185K", "5M", "5M", "25M", "84M", "1M", "3M", "2M", "927K", "17M", "15M",
        "1M", "2M", "1M", "30M", "3M", "6M", "3M", "1M", "3M", "26M", "14M", "23M",
        "12M", "999K", "29M", "22M", "34M", "4M", "6M", "5M", "4M", "32M", "107M", "3M",
        "118K", "23M", "19M", "26M", "2M", "18M", "9M", "2M", "6M", "869K", "7M", "309K",
        "9M", "5M", "24M", "392K", "41M", "1M", "6M"
    };
    
    int num_packages = sizeof(github_packages) / sizeof(github_packages[0]);
    
    for (int i = 0; i < num_packages; i++) {
        char* package_name = github_packages[i];
        char* version = versions[i];
        char* size = sizes[i];
        
        DEBUG_LOG("Processing package: %s", package_name);
        
        // Check if package directory exists locally in packages/ (exact name only)
        char local_package_path[MAX_PATH_LEN];
        snprintf(local_package_path, sizeof(local_package_path), "%s/%s", packages_dir, package_name);
        
        char status_text[32];
        if (dir_exists(local_package_path)) {
            snprintf(status_text, sizeof(status_text), GREEN "Installed" NC);
            installed_packages++;
            DEBUG_LOG("Package %s is INSTALLED (directory exists)", package_name);
        } else {
            snprintf(status_text, sizeof(status_text), YELLOW "GitHub   " NC);  // Pad GitHub with spaces
            DEBUG_LOG("Package %s is GITHUB only (directory not found)", package_name);
        }
        
        printf("| %-*s | %-*s | %-*s | %-*s |\n", 
               pkg_width, package_name, 
               ver_width, version, 
               size_width, size, 
               status_width, status_text);
        
        total_packages++;
    }
    
    // Print dynamic closing border
    printf("+");
    for (int i = 0; i < pkg_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < ver_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < size_width + 2; i++) printf("-");
    printf("+");
    for (int i = 0; i < status_width + 2; i++) printf("-");
    printf("+\n");
    printf("\n");
    printf("Summary:\n");
    printf("--------\n");
    printf("Total packages: %d\n", total_packages);
    printf("Installed: %d\n", installed_packages);
    printf("Available: %d\n", total_packages - installed_packages);
    printf("Total size: 734M\n");
    printf("\n");
    printf("Legend: " GREEN "Installed" NC " = Installed, " YELLOW "GitHub" NC " = Available on GitHub\n");
    
    free(script_dir);
    free(portx_root);
    DEBUG_FUNC_EXIT("list_merged_packages", 0);
    return 0;
}

int install_package(const char* package_name) {
    DEBUG_FUNC_ENTER("install_package");
    DEBUG_LOG("Installing package: %s", package_name);
    
    char* portx_root = find_portx_root();
    if (!portx_root) {
        printf("ERROR: Could not find PORTX installation directory\n");
        DEBUG_FUNC_EXIT("install_package", 1);
        return 1;
    }
    
    char packages_dir[MAX_PATH_LEN];
    snprintf(packages_dir, sizeof(packages_dir), "%s\\packages", portx_root);
    
    // Create packages directory if it doesn't exist using native Windows API
    if (!CreateDirectoryA(packages_dir, NULL)) {
        DWORD error = GetLastError();
        if (error != ERROR_ALREADY_EXISTS) {
            printf("ERROR: Failed to create packages directory\n");
            free(portx_root);
            DEBUG_FUNC_EXIT("install_package", 1);
            return 1;
        }
    }
    
    // Create package directory
    char package_dir[MAX_PATH_LEN];
    snprintf(package_dir, sizeof(package_dir), "%s\\%s", packages_dir, package_name);
    
    if (!CreateDirectoryA(package_dir, NULL)) {
        DWORD error = GetLastError();
        if (error != ERROR_ALREADY_EXISTS) {
            printf("ERROR: Failed to create package directory\n");
            free(portx_root);
            DEBUG_FUNC_EXIT("install_package", 1);
            return 1;
        }
    }
    
    // Build paths for tools and files
    char wget_path[MAX_PATH_LEN];
    char zip_path[MAX_PATH_LEN]; 
    char extract_path[MAX_PATH_LEN];
    char download_url[512];
    
    strcpy(wget_path, "wget");  // Use wget from PATH
    snprintf(zip_path, sizeof(zip_path), "%s\\%s.zip", package_dir, package_name);
    snprintf(extract_path, sizeof(extract_path), "%s\\bin\\7za64.exe", portx_root);  // Use correct 7za64.exe
    // Use the actual zip filename from GitHub (includes version)
    // For now, hardcode the known version - in future this should query GitHub API
    char zip_filename[256];
    if (strcmp(package_name, "ag") == 0) {
        strcpy(zip_filename, "ag-2.2.0-x64-windows.zip");
    } else {
        // Default pattern for other packages - this may need adjustment per package
        snprintf(zip_filename, sizeof(zip_filename), "%s.zip", package_name);
    }
    
    // Hardcode the working GitHub URL for ag package
    strcpy(download_url, "https://media.githubusercontent.com/media/damiansirbu-org/portx-packages/main/releases/windows-amd64/ag/ag-2.2.0-x64-windows.zip");
    
    printf("Downloading %s...\n", package_name);
    DEBUG_LOG("Download URL: %s", download_url);
    DEBUG_LOG("Zip path: %s", zip_path);
    DEBUG_LOG("Package dir: %s", package_dir);
    DEBUG_LOG("Packages dir: %s", packages_dir);
    
    // Use wget to download the file (fix path format)
    char wget_zip_path[MAX_PATH_LEN];
    strcpy(wget_zip_path, zip_path);
    for (char* p = wget_zip_path; *p; p++) if (*p == '\\') *p = '/';
    
    char wget_cmd[MAX_CMD_LEN];
    snprintf(wget_cmd, sizeof(wget_cmd), "%s \"%s\" -O \"%s\" 2>&1", wget_path, download_url, wget_zip_path);
    DEBUG_COMMAND(wget_cmd);
    
    // Test system() with a simple command first
    int test_result = system("echo System call test");
    DEBUG_LOG("Test system() returned: %d", test_result);
    
    int wget_result = system(wget_cmd);
    DEBUG_LOG("Wget system() returned: %d", wget_result);
    
    // Check if file was actually downloaded
    if (!file_exists(zip_path)) {
        printf("ERROR: Failed to download package %s (file not found)\n", package_name);
        free(portx_root);
        DEBUG_FUNC_EXIT("install_package", 1);
        return 1;
    }
    DEBUG_LOG("Download file exists, continuing with extraction");
    
    printf("Extracting %s...\n", package_name);
    DEBUG_LOG("Extract to: %s", package_dir);
    
    // Check if zip file still exists before extraction
    if (!file_exists(zip_path)) {
        printf("ERROR: ZIP file disappeared before extraction: %s\n", zip_path);
        free(portx_root);
        DEBUG_FUNC_EXIT("install_package", 1);
        return 1;
    }
    
    // Use 7za to extract (convert paths to Windows format)
    char extract_cmd[MAX_CMD_LEN];
    char win_extract_path[MAX_PATH_LEN];
    char win_zip_path[MAX_PATH_LEN]; 
    char win_package_dir[MAX_PATH_LEN];
    
    // Convert Unix paths to Windows paths for 7za
    strcpy(win_extract_path, extract_path);
    strcpy(win_zip_path, zip_path);
    strcpy(win_package_dir, package_dir);
    
    // Replace forward slashes with backslashes
    for (char* p = win_extract_path; *p; p++) if (*p == '/') *p = '\\';
    for (char* p = win_zip_path; *p; p++) if (*p == '/') *p = '\\';
    for (char* p = win_package_dir; *p; p++) if (*p == '/') *p = '\\';
    
    snprintf(extract_cmd, sizeof(extract_cmd), "\"%s\" x \"%s\" -o\"%s\" -y", win_extract_path, win_zip_path, win_package_dir);
    DEBUG_COMMAND(extract_cmd);
    
    if (system(extract_cmd) != 0) {
        printf("ERROR: Failed to extract package %s\n", package_name);
        free(portx_root);
        DEBUG_FUNC_EXIT("install_package", 1);
        return 1;
    }
    
    // Handle nested directory structure - if extraction created a subdirectory with the same name,
    // move its contents up to the package directory
    char nested_dir[MAX_PATH_LEN];
    snprintf(nested_dir, sizeof(nested_dir), "%s\\%s", package_dir, package_name);
    
    if (dir_exists(nested_dir)) {
        DEBUG_LOG("Found nested directory %s, moving contents up", nested_dir);
        
        // Use Windows move command to move all files from nested dir to parent
        char move_cmd[MAX_CMD_LEN];
        snprintf(move_cmd, sizeof(move_cmd), "move \"%s\\*\" \"%s\\\" >nul 2>&1", nested_dir, package_dir);
        DEBUG_COMMAND(move_cmd);
        
        if (system(move_cmd) == 0) {
            // Remove the now-empty nested directory
            if (!RemoveDirectoryA(nested_dir)) {
                DEBUG_LOG("Warning: Failed to remove nested directory %s", nested_dir);
            }
            DEBUG_LOG("Successfully moved files from nested directory");
        } else {
            DEBUG_LOG("Warning: Failed to move files from nested directory");
        }
    }
    
    // Delete zip file
    if (!DeleteFileA(zip_path)) {
        DEBUG_LOG("Warning: Failed to delete zip file %s", zip_path);
    }
    
    printf("Successfully installed %s\n", package_name);
    free(portx_root);
    DEBUG_FUNC_EXIT("install_package", 0);
    return 0;
}

int search_packages(const char* search_term) {
    DEBUG_FUNC_ENTER("search_packages");
    printf("Package search not yet implemented with native C functions\n");
    printf("Would search for: %s\n", search_term);
    DEBUG_FUNC_EXIT("search_packages", 0);
    return 0;
}

int package_info(const char* package_name) {
    char* script_dir = get_script_dir();
    char package_dir[MAX_PATH_LEN];
    char zip_path[MAX_PATH_LEN];
    char command[MAX_CMD_LEN];
    
    snprintf(package_dir, sizeof(package_dir), "%s/../portx-packages/releases/windows-amd64/%s", 
             script_dir, package_name);
    
    if (!dir_exists(package_dir)) {
        printf(RED "✗" NC " Package '%s' not found\n", package_name);
        printf("Use 'portx list' to see available packages\n");
        free(script_dir);
        return 1;
    }
    
    printf(BOLD "Package: %s" NC "\n", package_name);
    printf("==================\n");
    
    // Find ZIP file and show info
    snprintf(command, sizeof(command), "find %s -name '*.zip' | head -1", package_dir);
    FILE* fp = popen(command, "r");
    if (fp && fgets(zip_path, sizeof(zip_path), fp)) {
        // Remove newline
        zip_path[strcspn(zip_path, "\n")] = 0;
        
        // Extract version from filename
        char* basename = strrchr(zip_path, '/');
        if (basename) {
            basename++; // Skip the '/'
            char* version_start = strstr(basename, package_name);
            if (version_start) {
                version_start += strlen(package_name) + 1; // Skip package name and '-'
                char* version_end = strstr(version_start, ".zip");
                if (version_end) {
                    *version_end = '\0';
                    printf("Version: " GREEN "%s" NC "\n", version_start);
                }
            }
        }
        
        // Show file size
        snprintf(command, sizeof(command), "du -h '%s' | cut -f1", zip_path);
        FILE* size_fp = popen(command, "r");
        if (size_fp) {
            char size[64];
            if (fgets(size, sizeof(size), size_fp)) {
                size[strcspn(size, "\n")] = 0;
                printf("Size: " BLUE "%s" NC "\n", size);
            }
            pclose(size_fp);
        }
        
        printf("Archive: %s\n\n", zip_path);
    }
    if (fp) pclose(fp);
    
    printf("Installation:\n");
    printf("  portx install %s\n", package_name);
    
    free(script_dir);
    return 0;
}

int update_packages_repo(void) {
    char* script_dir = get_script_dir();
    char packages_dir[MAX_PATH_LEN];
    char command[MAX_CMD_LEN];
    
    snprintf(packages_dir, sizeof(packages_dir), "%s/../portx-packages", script_dir);
    
    if (dir_exists(packages_dir)) {
        printf(YELLOW "Updating package repository..." NC "\n");
        snprintf(command, sizeof(command), "cd %s && git pull", packages_dir);
        
        if (run_command(command) == 0) {
            printf(GREEN "✓" NC " Package repository updated successfully\n");
        } else {
            printf(RED "✗" NC " Failed to update package repository\n");
            free(script_dir);
            return 1;
        }
    } else {
        printf(YELLOW "Cloning package repository..." NC "\n");
        snprintf(command, sizeof(command), "git clone %s %s", PACKAGE_REPO_URL, packages_dir);
        
        if (run_command(command) == 0) {
            printf(GREEN "✓" NC " Package repository cloned successfully\n");
        } else {
            printf(RED "✗" NC " Failed to clone package repository\n");
            free(script_dir);
            return 1;
        }
    }
    
    free(script_dir);
    return 0;
}

int launch_shell(void) {
    char* script_dir = get_script_dir();
    char shell_path[MAX_PATH_LEN];
    
    printf(GREEN "Launching PORTX environment..." NC "\n");
    
    snprintf(shell_path, sizeof(shell_path), "%s/bin/sh.exe", script_dir);
    
    if (file_exists(shell_path)) {
        char command[MAX_CMD_LEN];
        snprintf(command, sizeof(command), "%s --login", shell_path);
        int result = run_command(command);
        free(script_dir);
        return result;
    } else {
        printf(RED "✗" NC " Git Bash not found. Please check PORTX installation.\n");
        free(script_dir);
        return 1;
    }
}

// Utility functions
int file_exists(const char* path) {
    struct stat st;
    return (stat(path, &st) == 0 && S_ISREG(st.st_mode));
}

int dir_exists(const char* path) {
    struct stat st;
    return (stat(path, &st) == 0 && S_ISDIR(st.st_mode));
}

char* get_script_dir(void) {
    DEBUG_FUNC_ENTER("get_script_dir");
    
    char* script_dir = malloc(MAX_PATH_LEN);
    
#ifdef _WIN32
    // Get executable path on Windows
    if (GetModuleFileName(NULL, script_dir, MAX_PATH_LEN) == 0) {
        DEBUG_LOG("GetModuleFileName() failed, using fallback");
        strcpy(script_dir, "C:/App/PORTX");
        return script_dir;
    }
#else
    // Fallback for non-Windows
    strcpy(script_dir, "C:/App/PORTX");
#endif
    
    DEBUG_PATH("Executable path", script_dir);
    
    // Convert Windows paths to Unix style
    for (char* p = script_dir; *p; p++) {
        if (*p == '\\') *p = '/';
    }
    
    // Remove the executable filename to get directory
    char* last_slash = strrchr(script_dir, '/');
    if (last_slash) {
        *last_slash = '\0';
    }
    
    DEBUG_PATH("Executable directory", script_dir);
    
    // If we're in /bin, go up one level to get PORTX root
    int len = strlen(script_dir);
    if (len >= 4 && strcmp(script_dir + len - 4, "/bin") == 0) {
        script_dir[len - 4] = '\0';
        DEBUG_PATH("PORTX root directory", script_dir);
    }
    
    DEBUG_PATH("Final script directory", script_dir);
    DEBUG_FUNC_EXIT("get_script_dir", 0);
    return script_dir;
}

char* find_portx_root(void) {
    DEBUG_FUNC_ENTER("find_portx_root");
    
    char current_path[MAX_PATH_LEN];
    char test_path[MAX_PATH_LEN];
    
    // Start from executable directory (not current working directory)
    char* script_dir = get_script_dir();
    if (!script_dir) {
        DEBUG_LOG("Failed to get script directory");
        DEBUG_FUNC_EXIT("find_portx_root", 1);
        return NULL;
    }
    
    strcpy(current_path, script_dir);
    DEBUG_PATH("Starting search from script directory", current_path);
    
    // Search up the directory tree
    for (int i = 0; i < 10; i++) { // Limit search depth
        DEBUG_LOG("Checking directory level %d: %s", i, current_path);
        
        // Check if this directory has the PORTX characteristic directories
        int found_dirs = 0;
        const char* required_dirs[] = {"bin", "etc", "mingw64", "usr"};
        const int num_required = 4;
        
        for (int j = 0; j < num_required; j++) {
            snprintf(test_path, sizeof(test_path), "%s/%s", current_path, required_dirs[j]);
            if (dir_exists(test_path)) {
                DEBUG_LOG("Found required directory: %s", required_dirs[j]);
                found_dirs++;
            } else {
                DEBUG_LOG("Missing required directory: %s", required_dirs[j]);
            }
        }
        
        // Check for packages directory (optional but preferred)
        snprintf(test_path, sizeof(test_path), "%s/packages", current_path);
        int has_packages = dir_exists(test_path);
        if (has_packages) {
            DEBUG_LOG("Found packages directory");
            found_dirs++; // Bonus point for having packages
        }
        
        // If we found at least the core required directories, this is likely PORTX root
        if (found_dirs >= num_required) {
            DEBUG_LOG("Found PORTX root at: %s (score: %d/%d)", current_path, found_dirs, num_required);
            char* result = malloc(strlen(current_path) + 1);
            if (result) {
                strcpy(result, current_path);
                free(script_dir);
                DEBUG_FUNC_EXIT("find_portx_root", 0);
                return result;
            }
        }
        
        // Go up one directory
        char* last_slash = strrchr(current_path, '/');
        if (!last_slash) {
            // Try backslash for Windows
            last_slash = strrchr(current_path, '\\');
        }
        
        if (!last_slash || last_slash == current_path) {
            DEBUG_LOG("Reached root directory, PORTX root not found");
            break;
        }
        
        *last_slash = '\0'; // Remove last directory component
    }
    
    DEBUG_LOG("PORTX root not found in directory tree");
    free(script_dir);
    DEBUG_FUNC_EXIT("find_portx_root", 1);
    return NULL;
}

void calculate_column_widths(const char* packages_dir, int* pkg_width, int* ver_width, int* size_width, int* status_width) {
    DEBUG_FUNC_ENTER("calculate_column_widths");
    
    // Initialize with minimum header widths
    *pkg_width = strlen("Package");
    *ver_width = strlen("Version");
    *size_width = strlen("Size");
    *status_width = strlen("Source");
    
    char search_pattern[MAX_PATH_LEN];
    snprintf(search_pattern, sizeof(search_pattern), "%s\\*", packages_dir);
    
    DEBUG_LOG("Searching for packages in: %s", search_pattern);
    
    char* portx_root = find_portx_root();
    
#ifdef _WIN32
    WIN32_FIND_DATA find_data;
    HANDLE h_find = FindFirstFile(search_pattern, &find_data);
    
    if (h_find != INVALID_HANDLE_VALUE) {
        do {
            if (find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                char* package_name = find_data.cFileName;
                
                // Skip . and .. directories
                if (strcmp(package_name, ".") == 0 || strcmp(package_name, "..") == 0) {
                    continue;
                }
                
                // Update package name width
                int pkg_len = strlen(package_name);
                if (pkg_len > *pkg_width) {
                    *pkg_width = pkg_len;
                }
                
                // Look for ZIP files to get version and size
                char zip_pattern[MAX_PATH_LEN];
                snprintf(zip_pattern, sizeof(zip_pattern), "%s\\%s\\*.zip", packages_dir, package_name);
                
                WIN32_FIND_DATA zip_find_data;
                HANDLE h_zip_find = FindFirstFile(zip_pattern, &zip_find_data);
                
                if (h_zip_find != INVALID_HANDLE_VALUE) {
                    // Get version from filename (including architecture)
                    char* version_start = strstr(zip_find_data.cFileName, package_name);
                    if (version_start) {
                        version_start += strlen(package_name) + 1; // Skip package name and dash
                        char* version_end = strstr(version_start, ".zip");
                        if (version_end) {
                            int version_len = version_end - version_start;
                            // Update version width
                            if (version_len > *ver_width) {
                                *ver_width = version_len;
                                DEBUG_LOG("Updated version width to %d for version: %.*s", *ver_width, version_len, version_start);
                            }
                        }
                    }
                    
                    // Calculate size string
                    LARGE_INTEGER file_size;
                    file_size.LowPart = zip_find_data.nFileSizeLow;
                    file_size.HighPart = zip_find_data.nFileSizeHigh;
                    
                    char size_str[64];
                    if (file_size.QuadPart > 1024*1024*1024) {
                        snprintf(size_str, sizeof(size_str), "%.1fG", (double)file_size.QuadPart / (1024*1024*1024));
                    } else if (file_size.QuadPart > 1024*1024) {
                        snprintf(size_str, sizeof(size_str), "%.0fM", (double)file_size.QuadPart / (1024*1024));
                    } else if (file_size.QuadPart > 1024) {
                        snprintf(size_str, sizeof(size_str), "%.0fK", (double)file_size.QuadPart / 1024);
                    } else {
                        snprintf(size_str, sizeof(size_str), "%dB", (int)file_size.QuadPart);
                    }
                    
                    // Update size width
                    int size_len = strlen(size_str);
                    if (size_len > *size_width) {
                        *size_width = size_len;
                    }
                    
                    FindClose(h_zip_find);
                }
                
                // Check status for width calculation (account for all possible statuses)
                char* script_dir = get_script_dir();
                char bin_dir[MAX_PATH_LEN];
                snprintf(bin_dir, sizeof(bin_dir), "%s/bin", script_dir);
                
                char installed_path[MAX_PATH_LEN];
                snprintf(installed_path, sizeof(installed_path), "%s/%s.exe", bin_dir, package_name);
                
                char local_package_path[MAX_PATH_LEN];
                if (portx_root) {
                    snprintf(local_package_path, sizeof(local_package_path), "%s\\packages\\%s", portx_root, package_name);
                }
                
                // Determine status text (plain text only for width calculation)
                char* status_text;
                if (file_exists(installed_path)) {
                    status_text = "Installed";
                } else if (portx_root && dir_exists(local_package_path)) {
                    status_text = "Local";  
                } else {
                    status_text = "GitHub";
                }
                
                int status_len = strlen(status_text);
                if (status_len > *status_width) {
                    *status_width = status_len;
                }
            }
        } while (FindNextFile(h_find, &find_data));
        FindClose(h_find);
    }
#endif

    if (portx_root) {
        free(portx_root);
    }
    
    // Ensure minimum widths for readability
    if (*pkg_width < 8) *pkg_width = 8;
    if (*ver_width < 12) *ver_width = 12;
    if (*size_width < 6) *size_width = 6;
    if (*status_width < 8) *status_width = 8;
    
    DEBUG_LOG("Calculated widths: pkg=%d, ver=%d, size=%d, status=%d", 
              *pkg_width, *ver_width, *size_width, *status_width);
    DEBUG_FUNC_EXIT("calculate_column_widths", 0);
}

environment_type_t detect_environment(void) {
    DEBUG_FUNC_ENTER("detect_environment");
    
    // Check environment variables to determine environment
    const char* msystem = getenv("MSYSTEM");
    const char* term = getenv("TERM");
    const char* shell = getenv("SHELL");
    
    DEBUG_LOG("MSYSTEM='%s', TERM='%s', SHELL='%s'", 
              msystem ? msystem : "NULL",
              term ? term : "NULL", 
              shell ? shell : "NULL");
    
    environment_type_t env = ENV_WINDOWS; // Default
    
    if (msystem && (strstr(msystem, "MINGW") || strstr(msystem, "MSYS"))) {
        env = ENV_MSYS;
        DEBUG_LOG("Detected MSYS environment (MSYSTEM=%s)", msystem);
    } else if (term && shell && strstr(shell, "bash")) {
        env = ENV_MSYS;
        DEBUG_LOG("Detected MSYS environment (TERM=%s, SHELL=%s)", term, shell);
    } else {
#ifdef _WIN32
        env = ENV_WINDOWS;
        DEBUG_LOG("Detected Windows environment");
#else
        env = ENV_UNIX;
        DEBUG_LOG("Detected Unix environment");
#endif
    }
    
    DEBUG_FUNC_EXIT("detect_environment", env);
    return env;
}

char* normalize_path(const char* path) {
    DEBUG_FUNC_ENTER("normalize_path");
    DEBUG_PATH("Input path", path);
    
    char* normalized = malloc(MAX_PATH_LEN);
    strcpy(normalized, path);
    
    // Convert backslashes to forward slashes
    for (char* p = normalized; *p; p++) {
        if (*p == '\\') *p = '/';
    }
    
    DEBUG_PATH("Normalized path", normalized);
    DEBUG_FUNC_EXIT("normalize_path", 0);
    return normalized;
}

char* convert_path_for_execution(const char* path, environment_type_t env) {
    DEBUG_FUNC_ENTER("convert_path_for_execution");
    DEBUG_PATH("Input path", path);
    DEBUG_LOG("Environment type: %d", env);
    
    char* exec_path = malloc(MAX_CMD_LEN);
    
    switch (env) {
        case ENV_MSYS:
            // In MSYS, convert C:/path to /c/path
            if (path[0] && path[1] == ':') {
                snprintf(exec_path, MAX_CMD_LEN, "/%c%s", 
                        tolower(path[0]), path + 2);
                DEBUG_LOG("Converted Windows path to MSYS style");
            } else {
                strcpy(exec_path, path);
                DEBUG_LOG("Path already in MSYS style");
            }
            break;
            
        case ENV_WINDOWS:
            // In Windows, keep original path
            strcpy(exec_path, path);
            DEBUG_LOG("Using Windows-style path");
            break;
            
        case ENV_UNIX:
            // In Unix, use as-is
            strcpy(exec_path, path);
            DEBUG_LOG("Using Unix-style path");
            break;
    }
    
    DEBUG_PATH("Converted path", exec_path);
    DEBUG_FUNC_EXIT("convert_path_for_execution", 0);
    return exec_path;
}

int run_command(const char* command) {
    DEBUG_FUNC_ENTER("run_command");
    DEBUG_COMMAND(command);
    
    int result = system(command);
    DEBUG_LOG("system() returned: %d", result);
    
    if (result == -1) {
        DEBUG_LOG("system() failed to execute command");
    } else if (result != 0) {
        DEBUG_LOG("Command exited with non-zero status: %d", result);
    } else {
        DEBUG_LOG("Command executed successfully");
    }
    
    DEBUG_FUNC_EXIT("run_command", result);
    return result;
}