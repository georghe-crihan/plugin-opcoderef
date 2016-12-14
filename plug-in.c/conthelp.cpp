/*
 *  This is a sample plugin module
 *
 *  It can be compiled by any of the supported compilers:
 *
 *      - Borland C++, CBuilder, free C++
 *      - Watcom C++ for DOS32
 *      - Watcom C++ for OS/2
 *      - Visual C++
 *
 */

#include <ida.hpp>
#include <idp.hpp>
//#include <bytes.hpp>
#include <loader.hpp>
//#include <kernwin.hpp>
#include <diskio.hpp>

#define MAXMNEM 20 /* Hope, the instruction will never get bigger! */

#define REVPOLY 0xEDB88320

#define SILENT 1 /* Suppress extra warnings */

static char PthBuf[MAXPATH];
static char MnmBuf[MAXMNEM];
static char TopBuf[MAXMNEM*2];

static
unsigned int crc32(unsigned char *instr)
{
 int   b, i;
 unsigned int crc = 0xFFFFFFFF;

 for (i=0; i < strlen((const char *)instr); i++) {
 crc ^= (unsigned long)toupper(instr[i]);
 for (b=0; b<8; b++)
    if (crc & 1)
       crc = (crc >> 1) ^ REVPOLY;
    else
       crc >>= 1;
    }
  return ~crc;
}

#if 0
//--------------------------------------------------------------------------
// This callback is called for UI notification events
static int idaapi sample_callback(void * /*user_data*/, int event_id, va_list /*va*/)
{
  if ( event_id != ui_msg )     // avoid recursion
    if ( event_id != ui_setstate
      && event_id != ui_showauto
      && event_id != ui_refreshmarked ) // ignore uninteresting events
                    msg("ui_callback %d\n", event_id);
  return 0;                     // 0 means "process the event"
                                // otherwise the event would be ignored
}

//--------------------------------------------------------------------------
// A sample how to generate user-defined line prefixes
static const int prefix_width = 8;

static void get_user_defined_prefix(ea_t ea,
                                    int lnnum,
                                    int indent,
                                    const char *line,
                                    char *buf,
                                    size_t bufsize)
{
  buf[0] = '\0';        // empty prefix by default

  // We want to display the prefix only the lines which
  // contain the instruction itself

  if ( indent != -1 ) return;           // a directive
  if ( line[0] == '\0' ) return;        // empty line
  if ( tag_advance(line,1)[-1] == ash.cmnt[0] ) return; // comment line...

  // We don't want the prefix to be printed again for other lines of the
  // same instruction/data. For that we remember the line number
  // and compare it before generating the prefix

  static ea_t old_ea = BADADDR;
  static int old_lnnum;
  if ( old_ea == ea && old_lnnum == lnnum ) return;

  // Ok, seems that we found an instruction line. 

  // Let's display the size of the current item as the user-defined prefix
  ulong our_size = get_item_size(ea);

  // We don't bother about the width of the prefix
  // because it will be padded with spaces by the kernel

  qsnprintf(buf, bufsize, " %d", our_size);

  // Remember the address and line number we produced the line prefix for:
  old_ea = ea;
  old_lnnum = lnnum;

}
#endif

//--------------------------------------------------------------------------
//
//      Initialize.
//
//      IDA will call this function only once.
//      If this function returns PLGUIN_SKIP, IDA will never load it again.
//      If this function returns PLUGIN_OK, IDA will unload the plugin but
//      remember that the plugin agreed to work with the database.
//      The plugin will be loaded again if the user invokes it by
//      pressing the hotkey or selecting it from the menu.
//      After the second load the plugin will stay on memory.
//      If this function returns PLUGIN_KEEP, IDA will keep the plugin
//      in the memory. In this case the initialization function can hook
//      into the processor module and user interface notification points.
//      See the hook_to_notification_point() function.
//
//      In this example we check the input file format and make the decision.
//      You may or may not check any other conditions to decide what you do:
//      whether you agree to work with the database or not.
//
int idaapi init(void)
{
char PlgBuf[MAXPATH];
char *Ptr;

#if 0
  if ( inf.filetype == f_ELF ) return PLUGIN_SKIP;

// Please uncomment the following line to see how the notification works
//  hook_to_notification_point(HT_UI, sample_callback, NULL);

// Please uncomment the following line to see how the user-defined prefix works
//  set_user_defined_prefix(prefix_width, get_user_defined_prefix);
#endif

  
  wsprintf(TopBuf, "opcoderef%d.hlp", ph.id);
  wsprintf(PlgBuf, "%s\\plugins", idadir());
  if (!SearchPath(PlgBuf, TopBuf, 0, MAXPATH, PthBuf, &Ptr))
  return PLUGIN_SKIP;

  return PLUGIN_KEEP;
}

//--------------------------------------------------------------------------
//      Terminate.
//      Usually this callback is empty.
//      The plugin should unhook from the notification lists if
//      hook_to_notification_point() was used.
//
//      IDA will call this function when the user asks to exit.
//      This function won't be called in the case of emergency exits.

void idaapi term(void)
{
#if 0
  unhook_from_notification_point(HT_UI, sample_callback);
  set_user_defined_prefix(0, NULL);
#endif
}

//--------------------------------------------------------------------------
//
//      The plugin method
//
//      This is the main function of plugin.
//
//      It will be called when the user selects the plugin.
//
//              arg - the input argument, it can be specified in
//                    plugins.cfg file. The default is zero.
//
//

void idaapi run(int arg)
{
BOOL res;
HWND hWnd;

hWnd=GetActiveWindow();
ua_mnem(get_screen_ea(), MnmBuf, sizeof(MnmBuf));

wsprintf(TopBuf, "%s,%s", MnmBuf, MnmBuf);

switch (arg) {
  case 0:
//    res = WinHelp(hWnd, PthBuf, HELP_KEY, (DWORD) TopBuf);
    res = WinHelp(hWnd, PthBuf, HELP_PARTIALKEY, (DWORD) TopBuf);
    break;
  case 1:
  case 2:
  case 3:
  case 4:
  case 5:
    wsprintf(TopBuf, "%s%d", MnmBuf, arg);
    WinHelp(hWnd, PthBuf, HELP_CONTEXTPOPUP, crc32((unsigned char *)TopBuf));
  default:
  ;
  }

}

//--------------------------------------------------------------------------
char comment[] = "Context instruction set reference for IDA";

char help[] =
        "A sample plugin module\n"
        "\n"
        "This module shows you how to create plugin modules.\n"
        "\n"
        "It does nothing useful - just prints a message that is was called\n"
        "and shows the current address.\n";


//--------------------------------------------------------------------------
// This is the preferred name of the plugin module in the menu system
// The preferred name may be overriden in plugins.cfg file

char wanted_name[] = "context instruction set reference plugin";


// This is the preferred hotkey for the plugin module
// The preferred hotkey may be overriden in plugins.cfg file
// Note: IDA won't tell you if the hotkey is not correct
//       It will just disable the hotkey.

char wanted_hotkey[] = "Alt-0";


//--------------------------------------------------------------------------
//
//      PLUGIN DESCRIPTION BLOCK
//
//--------------------------------------------------------------------------

extern "C" plugin_t PLUGIN = {
  IDP_INTERFACE_VERSION,
  0,                    // plugin flags
  init,                 // initialize

  term,                 // terminate. this pointer may be NULL.

  run,                  // invoke plugin

  comment,              // long comment about the plugin
                        // it could appear in the status line
                        // or as a hint

  help,                 // multiline help about the plugin

  wanted_name,          // the preferred short name of the plugin
  wanted_hotkey         // the preferred hotkey to run the plugin
};
