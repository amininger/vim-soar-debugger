"""" Rosie Specific Functionality """"

function! OpenRosieDebugger()
	let agent_name = input('Enter agent name: ', 'H-layout')
	let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	Python agent.connect()
endfunction

function! OpenRosieThorDebugger()
	let agent_name = input('Enter agent name: ', 'ai2thor')
	let config_file = $ROSIE_HOME."/test-agents/".agent_name."/agent/rosie.".agent_name.".config"
	call SetupDebuggerPanes()
	call SetupAgentMethods()
	Python from VimRosieAgent import VimRosieAgent
	Python agent = VimRosieAgent(writer, config_filename=vim.eval("config_file"))
	call LaunchAi2ThorSimulator()
	Python agent.connect()
endfunction

function! LaunchAi2ThorSimulator()
Python << EOF

from rosiethor import Ai2ThorSimulator, PerceptionConnector, ActuationConnector

simulator = Ai2ThorSimulator()

agent.connectors["perception"] = PerceptionConnector(agent, simulator)
agent.connectors["perception"].print_handler = lambda message: writer.write(message)
agent.connectors["actuation"] = ActuationConnector(agent, simulator)
agent.connectors["actuation"].print_handler = lambda message: writer.write(message)

simulator.start()

EOF
endfunction

function! ListRosieMessages(A,L,P)
	if !exists("g:rosie_messages")
		let msgs = []
	else
		let msgs = g:rosie_messages
	endif

	let res = []
	let pattern = "^".a:A
	for msg in msgs
		if msg =~ pattern
			call add(res, msg)
		endif
	endfor
	return res
endfunction

Python << EOF
def send_message(msg):
	if len(msg.strip()) > 0:
		writer.write("Instr: " + msg, VimWriter.SIDE_PANE_TOP, clear=False, scroll=True)
		agent.connectors["language"].send_message(msg)
EOF

function! SendMessageToRosie()
	let msg = input('Enter message: ', "", "customlist,ListRosieMessages")
	Python send_message(vim.eval("msg"))
endfunction


function! ControlAi2ThorRobot()
	let key = getchar()
	"Loop until either ESC or X is pressed
	while key != 27 && key != 120
		if key == 119 "W
			Python if simulator: simulator.exec_simple_command("MoveAhead")
		elseif key == 97 "A
			Python if simulator: simulator.exec_simple_command("MoveLeft")
		elseif key == 115 "S
			Python if simulator: simulator.exec_simple_command("MoveBack")
		elseif key == 100 "D
			Python if simulator: simulator.exec_simple_command("MoveRight")
		elseif key == 113 "Q
			Python if simulator: simulator.exec_simple_command("RotateLeft")
		elseif key == 101 "E
			Python if simulator: simulator.exec_simple_command("RotateRight")
		elseif key == 114 "R
			Python if simulator: simulator.exec_simple_command("LookUp")
		elseif key == 102 "F
			Python if simulator: simulator.exec_simple_command("LookDown")
		endif
		let key = getchar()
	endwhile
endfunction


