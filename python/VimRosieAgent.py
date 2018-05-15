""" Initializes a Rosie agent in the soar vim debugger and will display chat and action info in different panes """
import sys
import vim

from pysoarlib import SoarAgent

from VimLanguageConnector import VimLanguageConnector
from ActionStackConnector import ActionStackConnector
from VimWriter import VimWriter

class VimRosieAgent(SoarAgent):
    def __init__(self, writer, config_filename=None):
        self.vim_writer = writer
        SoarAgent.__init__(self, config_filename=config_filename, 
                print_handler = lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True),
                spawn_debugger=False, write_to_stdout=True)

        if self.messages_file != None:
            with open(self.messages_file, 'r') as f:
                vim.command("let g:rosie_messages = [\"" + "\",\"".join([ line.rstrip('\n') for line in f.readlines()]) + "\"]")

        self.connectors["language"] = VimLanguageConnector(self, writer)
        self.connectors["language"].register_message_callback(lambda message: writer.write(message, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True))

        self.connectors["action_stack"] = ActionStackConnector(self, writer)

    def update_debugger_info(self):
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=False)

