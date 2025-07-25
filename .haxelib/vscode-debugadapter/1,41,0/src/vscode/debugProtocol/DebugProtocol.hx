package vscode.debugProtocol;

import haxe.extern.EitherType;
import haxe.DynamicAccess;

enum abstract MessageType(String) from String {
	var Request = "request";
	var Response = "response";
	var Event = "event";
}

/**
	Base class of requests, responses, and events.
**/
typedef ProtocolMessage = {
	/**
		Sequence number (also known as message ID). For protocol messages of type 'request' this ID can be used to cancel the request.
	**/
	var seq:Int;

	/**
		Message type.
		Values: 'request', 'response', 'event', etc.
	**/
	var type:MessageType;
}

/**
	A client or debug adapter initiated request.
**/
typedef Request<T> = ProtocolMessage & {
	/**
		The command to execute.
	**/
	var command:String;

	/**
		Object containing arguments for the command.
	**/
	var ?arguments:T;
}

/**
	A debug adapter initiated event.
**/
typedef Event<T> = ProtocolMessage & {
	/**
		Type of event.
	**/
	var event:String;

	/**
		Event-specific information.
	**/
	var ?body:T;
}

/**
	Response to a request.
**/
typedef Response<T> = ProtocolMessage & {
	/**
		Sequence number of the corresponding request.
	**/
	var request_seq:Int;

	/**
		Outcome of the request.
		If true, the request was successful and the 'body' attribute may contain the result of the request.
		If the value is false, the attribute 'message' contains the error in short form and the 'body' may contain additional information (see 'ErrorResponse.body.error').
	**/
	var success:Bool;

	/**
		The command requested.
	**/
	var command:String;

	/**
		Contains error message if success == false.
		This raw error might be interpreted by the frontend and is not shown in the UI.
		Some predefined values exist.
		Values:
		'cancelled': request was cancelled.
		etc.
	**/
	var ?message:String;

	/**
		Contains request result if success is true and optional error details if success is false.
	**/
	var ?body:T;
}

/**
	On error (whenever 'success' is false), the body can provide more details.
**/
typedef ErrorResponse = Response<{
	/**
		An optional, structured error message.
	**/
	var ?error:Message;
}>;

/**
	Cancel request; value of command field is 'cancel'.
	The 'cancel' request is used by the frontend in two situations:
	- to indicate that it is no longer interested in the result produced by a specific request issued earlier
	- to cancel a progress sequence. Clients should only call this request if the capability 'supportsCancelRequest' is true.
	This request has a hint characteristic: a debug adapter can only be expected to make a 'best effort' in honouring this request but there are no guarantees.
	The 'cancel' request may return an error if it could not cancel an operation but a frontend should refrain from presenting this error to end users.
	A frontend client should only call this request if the capability 'supportsCancelRequest' is true.
	The request that got canceled still needs to send a response back. This can either be a normal result ('success' attribute true)
	or an error response ('success' attribute false and the 'message' set to 'cancelled').
	Returning partial results from a cancelled request is possible but please note that a frontend client has no generic way for detecting that a response is partial or not.
	The progress that got cancelled still needs to send a 'progressEnd' event back.
	A client should not assume that progress just got cancelled after sending the 'cancel' request.
**/
typedef CancelRequest = Request<CancelArguments>;

/**
	Arguments for 'cancel' request.
**/
typedef CancelArguments = {
	/**
		The ID (attribute 'seq') of the request to cancel. If missing no request is cancelled.
		Both a 'requestId' and a 'progressId' can be specified in one request.
	**/
	var ?requestId:Int;

	/**
		The ID (attribute 'progressId') of the progress to cancel. If missing no progress is cancelled.
		Both a 'requestId' and a 'progressId' can be specified in one request.
	**/
	var ?progressId:String;
}

/**
	Response to 'cancel' request. This is just an acknowledgement, so no body field is required.
**/
typedef CancelResponse = Response<{}>;

/**
	Event message for 'initialized' event type.
	This event indicates that the debug adapter is ready to accept configuration requests (e.g. SetBreakpointsRequest, SetExceptionBreakpointsRequest).
	A debug adapter is expected to send this event when it is ready to accept configuration requests (but not before the 'initialize' request has finished).
	The sequence of events/requests is as follows:
	- adapters sends 'initialized' event (after the 'initialize' request has returned)
	- frontend sends zero or more 'setBreakpoints' requests
	- frontend sends one 'setFunctionBreakpoints' request (if capability 'supportsFunctionBreakpoints' is true)
	- frontend sends a 'setExceptionBreakpoints' request if one or more 'exceptionBreakpointFilters' have been defined (or if 'supportsConfigurationDoneRequest' is not defined or false)
	- frontend sends other future configuration requests
	- frontend sends one 'configurationDone' request to indicate the end of the configuration.
**/
typedef InitializedEvent = Event<Dynamic>;

enum abstract StopReason(String) to String {
	var Step = "step";
	var Breakpoint = "breakpoint";
	var Exception = "exception";
	var Pause = "pause";
	var Entry = "entry";
	var Goto = "goto";
	var FunctionBreakpoint = "function breakpoint";
	var DataBreakpoint = "data breakpoint";
	var InstructionBreakpoint = "instruction breakpoint";
}

typedef TStoppedEvent = {
	/**
		The reason for the event.
		For backward compatibility this string is shown in the UI if the 'description' attribute is missing (but it must not be translated).
		Values: 'step', 'breakpoint', 'exception', 'pause', 'entry', 'goto', 'function breakpoint', 'data breakpoint', etc.
	**/
	var reason:StopReason;

	/**
		The full reason for the event, e.g. 'Paused on exception'. This string is shown in the UI as is and must be translated.
	**/
	var ?description:String;

	/**
		The thread which was stopped.
	**/
	var ?threadId:Int;

	/**
		A value of true hints to the frontend that this event should not change the focus.
	**/
	var ?preserveFocusHint:Bool;

	/**
		Additional information. E.g. if reason is 'exception', text contains the exception name. This string is shown in the UI.
	**/
	var ?text:String;

	/**
		If 'allThreadsStopped' is true, a debug adapter can announce that all threads have stopped.
		- The client should use this information to enable that all threads can be expanded to access their stacktraces.
		- If the attribute is missing or false, only the thread with the given threadId can be expanded.
	**/
	var ?allThreadsStopped:Bool;
}

/**
	Event message for 'stopped' event type.
	The event indicates that the execution of the debuggee has stopped due to some condition.
	This can be caused by a break point previously set, a stepping request has completed, by executing a debugger statement etc.
**/
typedef StoppedEvent = Event<TStoppedEvent>;

typedef TContinuedEvent = {
	/**
		The thread which was continued.
	**/
	var threadId:Int;

	/**
		If 'allThreadsContinued' is true, a debug adapter can announce that all threads have continued.
	**/
	var ?allThreadsContinued:Bool;
}

/**
	Event message for 'continued' event type.
	The event indicates that the execution of the debuggee has continued.
	Please note: a debug adapter is not expected to send this event in response to a request that implies that execution continues, e.g. 'launch' or 'continue'.
	It is only necessary to send a 'continued' event if there was no previous request that implied this.
**/
typedef ContinuedEvent = Event<TContinuedEvent>;

typedef TExitedEvent = {
	/**
		The exit code returned from the debuggee.
	**/
	var exitCode:Int;
}

/**
	Event message for 'exited' event type.
	The event indicates that the debuggee has exited and returns its exit code.
**/
typedef ExitedEvent = Event<TExitedEvent>;

typedef TTerminatedEvent = {
	/**
		A debug adapter may set 'restart' to true (or to an arbitrary object) to request that the front end restarts the session.
		The value is not interpreted by the client and passed unmodified as an attribute '__restart' to the 'launch' and 'attach' requests.
	**/
	var ?restart:EitherType<Bool, {}>;
}

/**
	Event message for 'terminated' event type.
	The event indicates that debugging of the debuggee has terminated. This does **not** mean that the debuggee itself has exited.
**/
typedef TerminatedEvent = Event<TTerminatedEvent>;

enum abstract ThreadEventReason(String) to String {
	var Started = "started";
	var Exited = "exited";
}

typedef TThreadEvent = {
	/**
		The reason for the event.
		Values: 'started', 'exited', etc.
	**/
	var reason:ThreadEventReason;

	/**
		The identifier of the thread.
	**/
	var threadId:Int;
}

/**
	Event message for 'thread' event type.
	The event indicates that a thread has started or exited.
**/
typedef ThreadEvent = Event<TThreadEvent>;

enum abstract OutputEventCategory(String) to String {
	var Console = "console";
	var Stdout = "stdout";
	var Stderr = "stderr";
	var Telemetry = "telemetry";
}

enum abstract OutputEventGroup(String) to String {
	/**
		Start a new group in expanded mode. Subsequent output events are members of the group and should be shown indented.
		The 'output' attribute becomes the name of the group and is not indented.
	**/
	var Start = "start";

	/**
		Start a new group in collapsed mode. Subsequent output events are members of the group and should be shown indented (as soon as the group is expanded).
		The 'output' attribute becomes the name of the group and is not indented.
	**/
	var StartCollapsed = "startCollapsed";

	/**
		End the current group and decreases the indentation of subsequent output events.
		A non empty 'output' attribute is shown as the unindented end of the group.
	**/
	var End = "end";
}

typedef TOutputEvent = {
	/**
		The output category. If not specified, 'console' is assumed.
		Values: 'console', 'stdout', 'stderr', 'telemetry', etc.
	**/
	var ?category:OutputEventCategory;

	/**
		The output to report.
	**/
	var output:String;

	/**
		Support for keeping an output log organized by grouping related messages.
	**/
	var ?group:OutputEventGroup;

	/**
		If an attribute 'variablesReference' exists and its value is > 0, the output contains objects which can be retrieved by passing 'variablesReference' to the 'variables' request.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?variablesReference:Int;

	/**
		An optional source location where the output was produced.
	**/
	var ?source:Source;

	/**
		An optional source location line where the output was produced.
	**/
	var ?line:Int;

	/**
		An optional source location column where the output was produced.
	**/
	var ?column:Int;

	/**
		Optional data to report. For the 'telemetry' category the data will be sent to telemetry, for the other categories the data is shown in JSON format.
	**/
	var data:Dynamic;
}

/**
	Event message for 'output' event type.
	The event indicates that the target has produced some output.
**/
typedef OutputEvent = Event<TOutputEvent>;

enum abstract BreakpointEventReason(String) to String {
	var Changed = "changed";
	var New = "new";
	var Removed = "removed";
}

typedef TBreakpointEvent = {
	/**
		The reason for the event.
		Values: 'changed', 'new', 'removed', etc.
	**/
	var reason:BreakpointEventReason;

	/**
		The 'id' attribute is used to find the target breakpoint and the other attributes are used as the new values.
	**/
	var breakpoint:Breakpoint;
}

/**
	Event message for 'breakpoint' event type.
	The event indicates that some information about a breakpoint has changed.
**/
typedef BreakpointEvent = Event<TBreakpointEvent>;

/**
	The reason for the module event.
**/
enum abstract ModuleEventReason(String) to String {
	var New = "new";
	var Changed = "changed";
	var Removed = "removed";
}

typedef TModuleEvent = {
	/**
		The reason for the event.
	**/
	var reason:ModuleEventReason;

	/**
		The new, changed, or removed module. In case of 'removed' only the module id is used.
	**/
	var module:Module;
}

/**
	Event message for 'module' event type.
	The event indicates that some information about a module has changed.
**/
typedef ModuleEvent = Event<TModuleEvent>;

enum abstract LoadedSourceEventReason(String) to String {
	var New = "new";
	var Changed = "changed";
	var Removed = "removed";
}

typedef TLoadedSourceEvent = {
	/**
		The reason for the event.
	**/
	var reason:LoadedSourceEventReason;

	/**
		The new, changed, or removed source.
	**/
	var source:Source;
}

/**
	Event message for 'loadedSource' event type.
	The event indicates that some source has been added, changed, or removed from the set of all loaded sources.
**/
typedef LoadedSourceEvent = Event<TLoadedSourceEvent>;

enum abstract ProcessEventStartMethod(String) {
	/**
		Process was launched under the debugger.
	**/
	var Launch = "launch";

	/**
		Debugger attached to an existing process.
	**/
	var Attach = "attach";

	/**
		A project launcher component has launched a new process in a suspended state and then asked the debugger to attach.
	**/
	var AttachForSuspendedLaunch = "attachForSuspendedLaunch";
}

typedef TProcessEvent = {
	/**
		The logical name of the process. This is usually the full path to process's executable file. Example: /home/example/myproj/program.js.
	**/
	var name:String;

	/**
		The system process id of the debugged process. This property will be missing for non-system processes.
	**/
	var ?systemProcessId:Int;

	/**
		If true, the process is running on the same computer as the debug adapter.
	**/
	var ?isLocalProcess:Bool;

	/**
		Describes how the debug engine started debugging this process.
	**/
	var ?startMethod:ProcessEventStartMethod;

	/**
		The size of a pointer or address for this process, in bits. This value may be used by clients when formatting addresses for display.
	**/
	var ?pointerSize:Int;
}

/**
	Event message for 'process' event type.
	The event indicates that the debugger has begun debugging a new process. Either one that it has launched, or one that it has attached to.
**/
typedef ProcessEvent = Event<TProcessEvent>;

typedef TCapabilitiesEvent = {
	/**
		The set of updated capabilities.
	**/
	var capabilities:Capabilities;
}

/**
	Event message for 'capabilities' event type.
	The event indicates that one or more capabilities have changed.
	Since the capabilities are dependent on the frontend and its UI, it might not be possible to change that at random times (or too late).
	Consequently this event has a hint characteristic: a frontend can only be expected to make a 'best effort' in honouring individual capabilities but there are no guarantees.
	Only changed capabilities need to be included, all other capabilities keep their values.
**/
typedef CapabilitiesEvent = Event<TCapabilitiesEvent>;

typedef TProgressStartEvent = {
	/** 
		An ID that must be used in subsequent 'progressUpdate' and 'progressEnd' events to make them refer to the same progress reporting.
		IDs must be unique within a debug session.
	**/
	var progressId:String;

	/**
		Mandatory (short) title of the progress reporting. Shown in the UI to describe the long running operation.
	**/
	var title:String;

	/**
		The request ID that this progress report is related to. If specified a debug adapter is expected to emit
		progress events for the long running request until the request has been either completed or cancelled.
		If the request ID is omitted, the progress report is assumed to be related to some general activity of the debug adapter.
	**/
	var ?requestId:Int;

	/**
		If true, the request that reports progress may be canceled with a 'cancel' request.
		So this property basically controls whether the client should use UX that supports cancellation.
		Clients that don't support cancellation are allowed to ignore the setting.
	**/
	var ?cancellable:Bool;

	/**
		Optional, more detailed progress message.
	**/
	var ?message:String;

	/**
		Optional progress percentage to display (value range: 0 to 100). If omitted no percentage will be shown.
	**/
	var ?percentage:Int;
}

/**
	Event message for 'progressStart' event type.
	The event signals that a long running operation is about to start and
	provides additional information for the client to set up a corresponding progress and cancellation UI.
	The client is free to delay the showing of the UI in order to reduce flicker.
	This event should only be sent if the client has passed the value true for the 'supportsProgressReporting' capability of the 'initialize' request.
**/
typedef ProgressStartEvent = Event<TProgressStartEvent>;

typedef TProgressUpdateEvent = {
	/**
		The ID that was introduced in the initial 'progressStart' event.
	**/
	var progressId:String;

	/**
		Optional, more detailed progress message. If omitted, the previous message (if any) is used.
	**/
	var ?message:String;

	/**
		Optional progress percentage to display (value range: 0 to 100). If omitted no percentage will be shown.
	**/
	var ?percentage:Int;
}

/**
	Event message for 'progressUpdate' event type.
	The event signals that the progress reporting needs to updated with a new message and/or percentage.
	The client does not have to update the UI immediately, but the clients needs to keep track of the message and/or percentage values.
	This event should only be sent if the client has passed the value true for the 'supportsProgressReporting' capability of the 'initialize' request.
**/
typedef ProgressUpdateEvent = Event<TProgressUpdateEvent>;

typedef TProgressEndEvent = {
	/**
		The ID that was introduced in the initial 'ProgressStartEvent'.
	**/
	var progressId:String;

	/**
		Optional, more detailed progress message. If omitted, the previous message (if any) is used.
	**/
	var ?message:String;
}

/**
	Event message for 'progressEnd' event type.
	The event signals the end of the progress reporting with an optional final message.
	This event should only be sent if the client has passed the value true for the 'supportsProgressReporting' capability of the 'initialize' request.
**/
typedef ProgressEndEvent = Event<TProgressEndEvent>;

/**
	RunInTerminal request; value of command field is 'runInTerminal'.
	This optional request is sent from the debug adapter to the client to run a command in a terminal.
	This is typically used to launch the debuggee in a terminal provided by the client.
	This request should only be called if the client has passed the value true for the 'supportsRunInTerminalRequest' capability of the 'initialize' request.
**/
typedef RunInTerminalRequest = Request<RunInTerminalRequestArguments>;

enum abstract RunInTerminalRequestArgumentsKind(String) {
	var Integrated = "integrated";
	var External = "external";
}

/**
	Arguments for 'runInTerminal' request.
**/
typedef RunInTerminalRequestArguments = {
	/**
		What kind of terminal to launch.
	**/
	var ?kind:RunInTerminalRequestArgumentsKind;

	/**
		Optional title of the terminal.
	**/
	var ?title:String;

	/**
		Working directory of the command.
	**/
	var cwd:String;

	/**
		List of arguments. The first argument is the command to run.
	**/
	var args:Array<String>;

	/**
		Environment key-value pairs that are added to the default environment.
	**/
	var ?env:DynamicAccess<String>;
}

/**
	Response to Initialize request.
**/
typedef RunInTerminalResponse = Response<{
	/**
		The process ID. The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?processId:Int;

	/**
		The process ID of the terminal shell. The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?shellProcessId:Int;
}>;

/**
	Initialize request; value of command field is 'initialize'.
	The 'initialize' request is sent as the first request from the client to the debug adapter
	in order to configure it with client capabilities and to retrieve capabilities from the debug adapter.
	Until the debug adapter has responded to with an 'initialize' response, the client must not send any additional requests or events to the debug adapter.
	In addition the debug adapter is not allowed to send any requests or events to the client until it has responded with an 'initialize' response.
	The 'initialize' request may only be sent once.
**/
typedef InitializeRequest = Request<InitializeRequestArguments>;

enum abstract InitializeRequestArgumentsPathFormat(String) {
	var Path = "path";
	var Uri = "uri";
}

/**
	Arguments for 'initialize' request.
**/
typedef InitializeRequestArguments = {
	/**
		The ID of the (frontend) client using this adapter.
	**/
	var ?clientID:String;

	/**
		The human readable name of the (frontend) client using this adapter.
	**/
	var ?clientName:String;

	/**
		The ID of the debug adapter.
	**/
	var adapterID:String;

	/**
		The ISO-639 locale of the (frontend) client using this adapter, e.g. en-US or de-CH.
	**/
	var ?locale:String;

	/**
		If true all line numbers are 1-based (default).
	**/
	var ?linesStartAt1:Bool;

	/**
		If true all column numbers are 1-based (default).
	**/
	var ?columnsStartAt1:Bool;

	/**
		Determines in what format paths are specified. The default is 'path', which is the native format.
		Values: 'path', 'uri', etc.
	**/
	var ?pathFormat:InitializeRequestArgumentsPathFormat;

	/**
		Client supports the optional type attribute for variables.
	**/
	var ?supportsVariableType:Bool;

	/**
		Client supports the paging of variables.
	**/
	var ?supportsVariablePaging:Bool;

	/**
		Client supports the runInTerminal request.
	**/
	var ?supportsRunInTerminalRequest:Bool;

	/**
		Client supports memory references.
	**/
	var ?supportsMemoryReferences:Bool;

	/**
		Client supports progress reporting.
	**/
	var ?supportsProgressReporting:Bool;
}

/**
	Response to 'initialize' request.
**/
typedef InitializeResponse = Response<Capabilities>;

/**
	ConfigurationDone request; value of command field is 'configurationDone'.
	This optional request indicates that the client has finished initialization of the debug adapter.
	So it is the last request in the sequence of configuration requests (which was started by the 'initialized' event).
	Clients should only call this request if the capability 'supportsConfigurationDoneRequest' is true.
**/
typedef ConfigurationDoneRequest = Request<ConfigurationDoneArguments>;

/**
	Arguments for 'configurationDone' request.
**/
typedef ConfigurationDoneArguments = {};

/**
	Response to 'configurationDone' request. This is just an acknowledgement, so no body field is required.
**/
typedef ConfigurationDoneResponse = Response<{}>;

/**
	Launch request; value of command field is 'launch'.
	This launch request is sent from the client to the debug adapter to start the debuggee with or without debugging (if 'noDebug' is true).
	Since launching is debugger/runtime specific, the arguments for this request are not part of this specification.
**/
typedef LaunchRequest = Request<LaunchRequestArguments>;

/**
	Arguments for 'launch' request. Additional attributes are implementation specific.
**/
typedef LaunchRequestArguments = {
	/**
		If noDebug is true the launch request should launch the program without enabling debugging.
	**/
	var ?noDebug:Bool;

	/**
		Optional data from the previous, restarted session.
		The data is sent as the 'restart' attribute of the 'terminated' event.
		The client should leave the data intact.
	**/
	var ?__restart:EitherType<Bool, {}>;
}

/**
	Response to 'launch' request. This is just an acknowledgement, so no body field is required.
**/
typedef LaunchResponse = Response<{}>;

/**
	Attach request; value of command field is 'attach'.
	The attach request is sent from the client to the debug adapter to attach to a debuggee that is already running.
	Since attaching is debugger/runtime specific, the arguments for this request are not part of this specification.
**/
typedef AttachRequest = Request<AttachRequestArguments>;

/**
	Arguments for 'attach' request. Additional attributes are implementation specific.
**/
typedef AttachRequestArguments = {
	/**
		Optional data from the previous, restarted session.
		The data is sent as the 'restart' attribute of the 'terminated' event.
		The client should leave the data intact.
	**/
	var ?__restart:EitherType<Bool, {}>;
}

/**
	Response to 'attach' request. This is just an acknowledgement, so no body field is required.
**/
typedef AttachResponse = Response<{}>;

/**
	Restart request; value of command field is 'restart'.
	Restarts a debug session. Clients should only call this request if the capability 'supportsRestartRequest' is true.
	If the capability is missing or has the value false, a typical client will emulate 'restart' by terminating the debug adapter first and then launching it anew.
**/
typedef RestartRequest = Request<RestartArguments>;

/**
	Arguments for 'restart' request.
**/
typedef RestartArguments = {}

/**
	Response to 'restart' request. This is just an acknowledgement, so no body field is required.
**/
typedef RestartResponse = Response<{}>;

/**
	Disconnect request; value of command field is 'disconnect'.
	The 'disconnect' request is sent from the client to the debug adapter in order to stop debugging.
	It asks the debug adapter to disconnect from the debuggee and to terminate the debug adapter.
	If the debuggee has been started with the 'launch' request, the 'disconnect' request terminates the debuggee.
	If the 'attach' request was used to connect to the debuggee, 'disconnect' does not terminate the debuggee.
	This behavior can be controlled with the 'terminateDebuggee' argument (if supported by the debug adapter).
**/
typedef DisconnectRequest = Request<DisconnectArguments>;

/**
	Arguments for 'disconnect' request.
**/
typedef DisconnectArguments = {
	/**
		A value of true indicates that this 'disconnect' request is part of a restart sequence.
	**/
	var ?restart:Bool;

	/**
		Indicates whether the debuggee should be terminated when the debugger is disconnected.
		If unspecified, the debug adapter is free to do whatever it thinks is best.
		The attribute is only honored by a debug adapter if the capability 'supportTerminateDebuggee' is true.
	**/
	var ?terminateDebuggee:Bool;
}

/**
	Response to 'disconnect' request. This is just an acknowledgement, so no body field is required.
**/
typedef DisconnectResponse = Response<{}>;

/**
	Terminate request; value of command field is 'terminate'.
	The 'terminate' request is sent from the client to the debug adapter in order to give the debuggee a chance for terminating itself.
	Clients should only call this request if the capability 'supportsTerminateRequest' is true.
**/
typedef TerminateRequest = Request<TerminateArguments>;

/**
	Arguments for 'terminate' request.
**/
typedef TerminateArguments = {
	/**
		A value of true indicates that this 'terminate' request is part of a restart sequence.
	**/
	var ?restart:Bool;
}

/**
	Response to 'terminate' request. This is just an acknowledgement, so no body field is required.
**/
typedef TerminateResponse = Response<{}>;

/**
	BreakpointLocations request; value of command field is 'breakpointLocations'.
	The 'breakpointLocations' request returns all possible locations for source breakpoints in a given range.
	Clients should only call this request if the capability 'supportsBreakpointLocationsRequest' is true.
**/
typedef BreakpointLocationsRequest = Request<BreakpointLocationsArguments>;

/**
	Arguments for 'breakpointLocations' request.
**/
typedef BreakpointLocationsArguments = {
	/**
		The source location of the breakpoints; either 'source.path' or 'source.reference' must be specified.
	**/
	var source:Source;

	/**
		Start line of range to search possible breakpoint locations in. If only the line is specified, the request returns all possible locations in that line.
	**/
	var line:Int;

	/**
		Optional start column of range to search possible breakpoint locations in. If no start column is given, the first column in the start line is assumed.
	**/
	var ?column:Int;

	/**
		Optional end line of range to search possible breakpoint locations in. If no end line is given, then the end line is assumed to be the start line.
	**/
	var ?endLine:Int;

	/**
		Optional end column of range to search possible breakpoint locations in. If no end column is given, then it is assumed to be in the last column of the end line.
	**/
	var ?endColumn:Int;
}

/**
	Response to 'breakpointLocations' request.
	Contains possible locations for source breakpoints.
**/
typedef BreakpointLocationsResponse = Response<{
	/**
		Sorted set of possible breakpoint locations.
	**/
	var breakpoints:Array<BreakpointLocation>;
}>;

/**
	SetBreakpoints request; value of command field is 'setBreakpoints'.
	Sets multiple breakpoints for a single source and clears all previous breakpoints in that source.
	To clear all breakpoint for a source, specify an empty array.
	When a breakpoint is hit, a 'stopped' event (with reason 'breakpoint') is generated.
**/
typedef SetBreakpointsRequest = Request<SetBreakpointsArguments>;

/**
	Arguments for "setBreakpoints" request.
**/
typedef SetBreakpointsArguments = {
	/**
		The source location of the breakpoints; either 'source.path' or 'source.reference' must be specified.
	**/
	var source:Source;

	/**
		The code locations of the breakpoints.
	**/
	var ?breakpoints:Array<SourceBreakpoint>;

	/**
		Deprecated: The code locations of the breakpoints.
	**/
	@:deprecated
	var ?lines:Array<Int>;

	/**
		A value of true indicates that the underlying source has been modified which results in new breakpoint locations.
	**/
	var ?sourceModified:Bool;
}

/**
	Response to 'setBreakpoints' request.
	Returned is information about each breakpoint created by this request.
	This includes the actual code location and whether the breakpoint could be verified.
	The breakpoints returned are in the same order as the elements of the 'breakpoints'
	(or the deprecated 'lines') array in the arguments.
**/
typedef SetBreakpointsResponse = Response<{
	/**
		Information about the breakpoints.
		The array elements are in the same order as the elements of the 'breakpoints' (or the deprecated 'lines') array in the arguments.
	**/
	var breakpoints:Array<Breakpoint>;
}>;

/**
	SetFunctionBreakpoints request; value of command field is 'setFunctionBreakpoints'.
	Replaces all existing function breakpoints with new function breakpoints.
	To clear all function breakpoints, specify an empty array.
	When a function breakpoint is hit, a 'stopped' event (with reason 'function breakpoint') is generated.
	Clients should only call this request if the capability 'supportsFunctionBreakpoints' is true.
**/
typedef SetFunctionBreakpointsRequest = Request<SetFunctionBreakpointsArguments>;

/**
	Arguments for 'setFunctionBreakpoints' request.
**/
typedef SetFunctionBreakpointsArguments = {
	/**
		The function names of the breakpoints.
	**/
	var breakpoints:Array<FunctionBreakpoint>;
};

/**
	Response to 'setFunctionBreakpoints' request.
	Returned is information about each breakpoint created by this request.
**/
typedef SetFunctionBreakpointsResponse = Response<{
	/**
		Information about the breakpoints. The array elements correspond to the elements of the 'breakpoints' array.
	**/
	var breakpoints:Array<Breakpoint>;
}>;

/**
	SetExceptionBreakpoints request; value of command field is 'setExceptionBreakpoints'.
	The request configures the debuggers response to thrown exceptions.
	If an exception is configured to break, a 'stopped' event is fired (with reason 'exception').
	Clients should only call this request if the capability 'exceptionBreakpointFilters' returns one or more filters
**/
typedef SetExceptionBreakpointsRequest = Request<SetExceptionBreakpointsArguments>;

/**
	Arguments for 'setExceptionBreakpoints' request.
**/
typedef SetExceptionBreakpointsArguments = {
	/**
		IDs of checked exception options. The set of IDs is returned via the 'exceptionBreakpointFilters' capability.
	**/
	var filters:Array<String>;

	/**
		Configuration options for selected exceptions.
		The attribute is only honored by a debug adapter if the capability 'supportsExceptionOptions' is true.
	**/
	var ?exceptionOptions:Array<ExceptionOptions>;
}

/**
	Response to 'setExceptionBreakpoints' request. This is just an acknowledgement, so no body field is required.
**/
typedef SetExceptionBreakpointsResponse = Response<{}>;

/**
	DataBreakpointInfo request; value of command field is 'dataBreakpointInfo'.
	Obtains information on a possible data breakpoint that could be set on an expression or variable.
	Clients should only call this request if the capability 'supportsDataBreakpoints' is true.
**/
typedef DataBreakpointInfoRequest = Request<DataBreakpointInfoArguments>;

/**
	Arguments for 'dataBreakpointInfo' request.
**/
typedef DataBreakpointInfoArguments = {
	/**
		Reference to the Variable container if the data breakpoint is requested for a child of the container.
	**/
	var ?variablesReference:Int;

	/**
		The name of the Variable's child to obtain data breakpoint information for.
		If variableReference isn’t provided, this can be an expression.
	**/
	var name:String;
}

/**
	Response to 'dataBreakpointInfo' request.
**/
typedef DataBreakpointInfoResponse = Response<{
	/**
		An identifier for the data on which a data breakpoint can be registered with the setDataBreakpoints request or null if no data breakpoint is available.
	**/
	var dataId:Null<String>;

	/**
		UI string that describes on what data the breakpoint is set on or why a data breakpoint is not available.
	**/
	var description:String;

	/**
		Optional attribute listing the available access types for a potential data breakpoint. A UI frontend could surface this information.
	**/
	var ?accessTypes:Array<DataBreakpointAccessType>;

	/**
		Optional attribute indicating that a potential data breakpoint could be persisted across sessions.
	**/
	var ?canPersist:Bool;
}>;

/**
	SetDataBreakpoints request; value of command field is 'setDataBreakpoints'.
	Replaces all existing data breakpoints with new data breakpoints.
	To clear all data breakpoints, specify an empty array.
	When a data breakpoint is hit, a 'stopped' event (with reason 'data breakpoint') is generated.
	Clients should only call this request if the capability 'supportsDataBreakpoints' is true.
**/
typedef SetDataBreakpointsRequest = Request<SetDataBreakpointsArguments>;

/**
	Arguments for 'setDataBreakpoints' request.
**/
typedef SetDataBreakpointsArguments = {
	/**
		The contents of this array replaces all existing data breakpoints. An empty array clears all data breakpoints.
	**/
	var breakpoints:Array<DataBreakpoint>;
}

/**
	Response to 'setDataBreakpoints' request.
	Returned is information about each breakpoint created by this request.
**/
typedef SetDataBreakpointsResponse = Response<{
	/**
		Information about the data breakpoints. The array elements correspond to the elements of the input argument 'breakpoints' array.
	**/
	var breakpoints:Array<Breakpoint>;
}>;

/**
	SetInstructionBreakpoints request; value of command field is 'setInstructionBreakpoints'.
	Replaces all existing instruction breakpoints. Typically, instruction breakpoints would be set from a diassembly window.
	To clear all instruction breakpoints, specify an empty array.
	When an instruction breakpoint is hit, a 'stopped' event (with reason 'instruction breakpoint') is generated.
	Clients should only call this request if the capability 'supportsInstructionBreakpoints' is true.
**/
typedef SetInstructionBreakpointsRequest = Request<SetInstructionBreakpointsArguments>;

/**
	Arguments for 'setInstructionBreakpoints' request
**/
typedef SetInstructionBreakpointsArguments = {
	/**
		The instruction references of the breakpoints
	**/
	var breakpoints:Array<InstructionBreakpoint>;
}

/**
	Response to 'setInstructionBreakpoints' request
**/
typedef SetInstructionBreakpointsResponse = Response<{
	/**
		Information about the breakpoints. The array elements correspond to the elements of the 'breakpoints' array.
	**/
	var breakpoints:Array<Breakpoint>;
}>;

/**
	Continue request; value of command field is 'continue'.
	The request starts the debuggee to run again.
**/
typedef ContinueRequest = Request<ContinueArguments>;

/**
	Arguments for 'continue' request.
**/
typedef ContinueArguments = {
	/**
		Continue execution for the specified thread (if possible).
		If the backend cannot continue on a single thread but will continue on all threads, it should set the 'allThreadsContinued' attribute in the response to true.
	**/
	var threadId:Int;
}

/**
	Response to 'continue' request.
**/
typedef ContinueResponse = Response<{
	/**
		If true, the 'continue' request has ignored the specified thread and continued all threads instead.
		If this attribute is missing a value of 'true' is assumed for backward compatibility.
	**/
	var ?allThreadsContinued:Bool;
}>;

/**
	Next request; value of command field is 'next'.
	The request starts the debuggee to run again for one step.
	The debug adapter first sends the response and then a 'stopped' event (with reason 'step') after the step has completed.
**/
typedef NextRequest = Request<NextArguments>;

/**
	Arguments for 'next' request.
**/
typedef NextArguments = {
	/**
		Execute 'next' for this thread.
	**/
	var threadId:Int;

	/**
		Optional granularity to step. If no granularity is specified, a granularity of 'statement' is assumed.
	**/
	var ?granularity:SteppingGranularity;
}

/**
	Response to 'next' request. This is just an acknowledgement, so no body field is required.
**/
typedef NextResponse = Response<{}>;

/**
	StepIn request; value of command field is 'stepIn'.
	The request starts the debuggee to step into a function/method if possible.
	If it cannot step into a target, 'stepIn' behaves like 'next'.
	The debug adapter first sends the response and then a 'stopped' event (with reason 'step') after the step has completed.
	If there are multiple function/method calls (or other targets) on the source line,
	the optional argument 'targetId' can be used to control into which target the 'stepIn' should occur.
	The list of possible targets for a given source line can be retrieved via the 'stepInTargets' request.
**/
typedef StepInRequest = Request<StepInArguments>;

/**
	Arguments for 'stepIn' request.
**/
typedef StepInArguments = {
	/**
		Execute 'stepIn' for this thread.
	**/
	var threadId:Int;

	/**
		Optional id of the target to step into.
	**/
	var ?targetId:Int;
}

/**
	Response to 'stepIn' request. This is just an acknowledgement, so no body field is required.
**/
typedef StepInResponse = Response<{}>;

/**
	StepOut request; value of command field is 'stepOut'.
	The request starts the debuggee to run again for one step.
	The debug adapter first sends the response and then a 'stopped' event (with reason 'step') after the step has completed.
**/
typedef StepOutRequest = Request<StepOutArguments>;

/**
	Arguments for 'stepOut' request.
**/
typedef StepOutArguments = {
	/**
		Execute 'stepOut' for this thread.
	**/
	var threadId:Int;

	/**
		Optional granularity to step. If no granularity is specified, a granularity of 'statement' is assumed.
	**/
	var ?granularity:SteppingGranularity;
}

/**
	Response to 'stepOut' request. This is just an acknowledgement, so no body field is required.
**/
typedef StepOutResponse = Response<{}>;

/**
	StepBack request; value of command field is 'stepBack'.
	The request starts the debuggee to run one step backwards.
	The debug adapter first sends the response and then a 'stopped' event (with reason 'step') after the step has completed.
	Clients should only call this request if the capability 'supportsStepBack' is true.
**/
typedef StepBackRequest = Request<StepBackArguments>;

/**
	Arguments for 'stepBack' request.
**/
typedef StepBackArguments = {
	/**
		Execute 'stepBack' for this thread.
	**/
	var threadId:Int;

	/**
		Optional granularity to step. If no granularity is specified, a granularity of 'statement' is assumed.
	**/
	var ?granularity:SteppingGranularity;
}

/**
	Response to 'stepBack' request. This is just an acknowledgement, so no body field is required.
**/
typedef StepBackResponse = Response<{}>;

/**
	ReverseContinue request; value of command field is 'reverseContinue'.
	The request starts the debuggee to run backward.
	Clients should only call this request if the capability 'supportsStepBack' is true.
**/
typedef ReverseContinueRequest = Request<ReverseContinueArguments>;

/**
	Arguments for 'reverseContinue' request.
**/
typedef ReverseContinueArguments = {
	/**
		Execute 'reverseContinue' for this thread.
	**/
	var threadId:Int;
}

/**
	Response to 'reverseContinue' request. This is just an acknowledgement, so no body field is required.
**/
typedef ReverseContinueResponse = Response<{}>;

/**
	RestartFrame request; value of command field is 'restartFrame'.
	The request restarts execution of the specified stackframe.
	The debug adapter first sends the response and then a 'stopped' event (with reason 'restart') after the restart has completed.
	Clients should only call this request if the capability 'supportsRestartFrame' is true.
**/
typedef RestartFrameRequest = Request<RestartFrameArguments>;

/**
	Arguments for 'restartFrame' request.
**/
typedef RestartFrameArguments = {
	/**
		Restart this stackframe.
	**/
	var frameId:Int;
}

/**
	Response to 'restartFrame' request. This is just an acknowledgement, so no body field is required.
**/
typedef RestartFrameResponse = Response<{}>;

/**
	Goto request; value of command field is 'goto'.
	The request sets the location where the debuggee will continue to run.
	This makes it possible to skip the execution of code or to executed code again.
	The code between the current location and the goto target is not executed but skipped.
	The debug adapter first sends the response and then a 'stopped' event with reason 'goto'.
	Clients should only call this request if the capability 'supportsGotoTargetsRequest' is true (because only then goto targets exist that can be passed as arguments).
**/
typedef GotoRequest = Request<GotoArguments>;

/**
	Arguments for 'goto' request.
**/
typedef GotoArguments = {
	/**
		Set the goto target for this thread.
	**/
	var threadId:Int;

	/**
		The location where the debuggee will continue to run.
	**/
	var targetId:Int;
}

/**
	Response to 'goto' request. This is just an acknowledgement, so no body field is required.
**/
typedef GotoResponse = Response<{}>;

/**
	Pause request; value of command field is 'pause'.
	The request suspends the debuggee.
	The debug adapter first sends the response and then a 'stopped' event (with reason 'pause') after the thread has been paused successfully.
**/
typedef PauseRequest = Request<PauseArguments>;

/**
	Arguments for 'pause' request.
**/
typedef PauseArguments = {
	var threadId:Int;
}

/**
	Response to 'pause' request. This is just an acknowledgement, so no body field is required.
**/
typedef PauseResponse = Response<{}>;

/**
	StackTrace request; value of command field is 'stackTrace'.
	The request returns a stacktrace from the current execution state.
**/
typedef StackTraceRequest = Request<StackTraceArguments>;

/**
	Arguments for 'stackTrace' request.
**/
typedef StackTraceArguments = {
	/**
		Retrieve the stacktrace for this thread.
	**/
	var threadId:Int;

	/**
		The index of the first frame to return; if omitted frames start at 0.
	**/
	var ?startFrame:Int;

	/**
		The maximum number of frames to return. If levels is not specified or 0, all frames are returned.
	**/
	var ?levels:Int;

	/**
		Specifies details on how to format the stack frames.
		The attribute is only honored by a debug adapter if the capability 'supportsValueFormattingOptions' is true.
	**/
	var ?format:StackFrameFormat;
}

/**
	Response to 'stackTrace' request.
**/
typedef StackTraceResponse = Response<{
	/**
		The frames of the stackframe. If the array has length zero, there are no stackframes available.
		This means that there is no location information available.
	**/
	var stackFrames:Array<StackFrame>;

	/**
		The total number of frames available.
	**/
	var ?totalFrames:Int;
}>;

/**
	Scopes request; value of command field is 'scopes'.
	The request returns the variable scopes for a given stackframe ID.
**/
typedef ScopesRequest = Request<ScopesArguments>;

/**
	Arguments for 'scopes' request.
**/
typedef ScopesArguments = {
	/**
		Retrieve the scopes for this stackframe.
	**/
	var frameId:Int;
}

/**
	Response to 'scopes' request.
**/
typedef ScopesResponse = Response<{
	/**
		The scopes of the stackframe. If the array has length zero, there are no scopes available.
	**/
	var scopes:Array<Scope>;
}>;

/**
	Variables request; value of command field is 'variables'.
	Retrieves all child variables for the given variable reference.
	An optional filter can be used to limit the fetched children to either named or indexed children.
**/
typedef VariablesRequest = Request<VariablesArguments>;

enum abstract VariableArgumentsFilter(String) {
	var Indexed = "indexed";
	var Named = "named";
}

/**
	Arguments for 'variables' request.
**/
typedef VariablesArguments = {
	/**
		The Variable reference.
	**/
	var variablesReference:Int;

	/**
		Optional filter to limit the child variables to either named or indexed. If ommited, both types are fetched.
	**/
	var ?filter:VariableArgumentsFilter;

	/**
		The index of the first variable to return; if omitted children start at 0.
	**/
	var ?start:Int;

	/**
		The number of variables to return. If count is missing or 0, all variables are returned.
	**/
	var ?count:Int;

	/**
		Specifies details on how to format the Variable values.
		The attribute is only honored by a debug adapter if the capability 'supportsValueFormattingOptions' is true.
	**/
	var ?format:ValueFormat;
}

/**
	Response to 'variables' request.
**/
typedef VariablesResponse = Response<{
	/**
		All (or a range) of variables for the given variable reference.
	**/
	var variables:Array<Variable>;
}>;

/**
	SetVariable request; value of command field is 'setVariable'.
	Set the variable with the given name in the variable container to a new value. Clients should only call this request if the capability 'supportsSetVariable' is true.
**/
typedef SetVariableRequest = Request<SetVariableArguments>;

/**
	Arguments for 'setVariable' request.
**/
typedef SetVariableArguments = {
	/**
		The reference of the variable container.
	**/
	var variablesReference:Int;

	/**
		The name of the variable.
	**/
	var name:String;

	/**
		The value of the variable.
	**/
	var value:String;

	/**
		Specifies details on how to format the response value.
	**/
	var ?format:ValueFormat;
}

/**
	Response to 'setVariable' request.
**/
typedef SetVariableResponse = Response<{
	/**
		The new value of the variable.
	**/
	var value:String;

	/**
		The type of the new value. Typically shown in the UI when hovering over the value.
	**/
	var ?type:String;

	/**
		If variablesReference is > 0, the new value is structured and its children can be retrieved by passing variablesReference to the VariablesRequest.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?variablesReference:Int;

	/** 
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?namedVariables:Int;

	/**
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?indexedVariables:Int;
}>;

/**
	Source request; value of command field is 'source'.
	The request retrieves the source code for a given source reference.
**/
typedef SourceRequest = Request<SourceArguments>;

/**
	Arguments for 'source' request.
**/
typedef SourceArguments = {
	/**
		Specifies the source content to load. Either source.path or source.sourceReference must be specified.
	**/
	var ?source:Source;

	/**
		The reference to the source. This is the same as source.sourceReference.
		This is provided for backward compatibility since old backends do not understand the 'source' attribute.
	**/
	var sourceReference:Int;
}

/**
	Response to 'source' request.
**/
typedef SourceResponse = Response<{
	/**
		Content of the source reference.
	**/
	var content:String;

	/**
		Optional content type (mime type) of the source.
	**/
	var ?mimeType:String;
}>;

/**
	Threads request; value of command field is 'threads'.
	The request retrieves a list of all threads.
**/
typedef ThreadsRequest = Request<{}>;

/**
	Response to 'threads' request.
**/
typedef ThreadsResponse = Response<{
	/**
		All threads.
	**/
	var threads:Array<Thread>;
}>;

/**
	TerminateThreads request; value of command field is 'terminateThreads'.
	The request terminates the threads with the given ids.
	Clients should only call this request if the capability 'supportsTerminateThreadsRequest' is true.
**/
typedef TerminateThreadsRequest = Request<TerminateThreadsArguments>;

/**
	Arguments for 'terminateThreads' request.
**/
typedef TerminateThreadsArguments = {
	/**
		Ids of threads to be terminated.
	**/
	var ?threadIds:Array<Int>;
}

/**
	Response to 'terminateThreads' request. This is just an acknowledgement, so no body field is required.
**/
typedef TerminateThreadsResponse = Response<{}>;

/**
	Modules request; value of command field is 'modules'.
	Modules can be retrieved from the debug adapter with this request which can either return all modules or a range of modules to support paging.
	Clients should only call this request if the capability 'supportsModulesRequest' is true.
**/
typedef ModulesRequest = Request<ModulesArguments>;

/**
	Arguments for 'modules' request.
**/
typedef ModulesArguments = {
	/**
		The index of the first module to return; if omitted modules start at 0.
	**/
	var ?startModule:Int;

	/**
		The number of modules to return. If moduleCount is not specified or 0, all modules are returned.
	**/
	var ?moduleCount:Int;
}

/**
	Response to 'modules' request.
**/
typedef ModulesResponse = Response<{
	/**
		All modules or range of modules.
	**/
	var modules:Array<Module>;

	/**
		The total number of modules available.
	**/
	var totalModules:Int;
}>;

/**
	LoadedSources request; value of command field is 'loadedSources'.
	Retrieves the set of all sources currently loaded by the debugged process.
	Clients should only call this request if the capability 'supportsLoadedSourcesRequest' is true.
**/
typedef LoadedSourcesRequest = Request<LoadedSourcesArguments>;

/**
	Arguments for 'loadedSources' request.
**/
typedef LoadedSourcesArguments = {}

/**
	Response to 'loadedSources' request.
**/
typedef LoadedSourcesResponse = Response<{
	/**
		Set of loaded sources.
	**/
	var sources:Array<Source>;
}>;

/**
	Evaluate request; value of command field is 'evaluate'.
	Evaluates the given expression in the context of the top most stack frame.
	The expression has access to any variables and arguments that are in scope.
**/
typedef EvaluateRequest = Request<EvaluateArguments>;

enum abstract EvaluateArgumentsContext(String) {
	/**
		evaluate is run in a watch.
	**/
	var Watch = "watch";

	/**
		evaluate is run from REPL console.
	**/
	var Repl = "repl";

	/**
		evaluate is run from a data hover.
	**/
	var Hover = "hover";

	/**
		evaluate is run to generate the value that will be stored in the clipboard.
		The attribute is only honored by a debug adapter if the capability 'supportsClipboardContext' is true.
	**/
	var Clipboard = "clipboard";
}

/**
	Arguments for 'evaluate' request.
**/
typedef EvaluateArguments = {
	/**
		The expression to evaluate.
	**/
	var expression:String;

	/**
		Evaluate the expression in the scope of this stack frame. If not specified, the expression is evaluated in the global scope.
	**/
	var ?frameId:Int;

	/**
		The context in which the evaluate request is run.
	**/
	var ?context:EvaluateArgumentsContext;

	/**
		Specifies details on how to format the Evaluate result.
		The attribute is only honored by a debug adapter if the capability 'supportsValueFormattingOptions' is true.
	**/
	var ?format:ValueFormat;
}

/**
	Response to 'evaluate' request.
**/
typedef EvaluateResponse = Response<{
	/**
		The result of the evaluate request.
	**/
	var result:String;

	/**
		The optional type of the evaluate result.
		This attribute should only be returned by a debug adapter if the client has passed the value true for the 'supportsVariableType' capability of the 'initialize' request.
	**/
	var ?type:String;

	/**
		If variablesReference is > 0, the evaluate result is structured and its children can be retrieved by passing variablesReference to the VariablesRequest.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var variablesReference:Int;

	/**
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?namedVariables:Int;

	/**
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?indexedVariables:Int;

	/**
		Optional memory reference to a location appropriate for this result.
		For pointer type eval results, this is generally a reference to the memory address contained in the pointer.
		This attribute should be returned by a debug adapter if the client has passed the value true for the 'supportsMemoryReferences' capability of the 'initialize' request.
	**/
	var ?memoryReference:String;
}>;

/**
	SetExpression request; value of command field is 'setExpression'.
	Evaluates the given 'value' expression and assigns it to the 'expression' which must be a modifiable l-value.
	The expressions have access to any variables and arguments that are in scope of the specified frame.
	Clients should only call this request if the capability 'supportsSetExpression' is true.
**/
typedef SetExpressionRequest = Request<SetExpressionArguments>;

/**
	Arguments for 'setExpression' request.
**/
typedef SetExpressionArguments = {
	/**
		The l-value expression to assign to.
	**/
	var expression:String;

	/**
		The value expression to assign to the l-value expression.
	**/
	var value:String;

	/**
		Evaluate the expressions in the scope of this stack frame. If not specified, the expressions are evaluated in the global scope.
	**/
	var ?frameId:Int;

	/**
		Specifies how the resulting value should be formatted.
	**/
	var ?format:ValueFormat;
}

/**
	Response to 'setExpression' request.
**/
typedef SetExpressionResponse = Response<{
	/**
		The new value of the expression.
	**/
	var value:String;

	/**
		The optional type of the value.
		This attribute should only be returned by a debug adapter if the client has passed the value true for the 'supportsVariableType' capability of the 'initialize' request.
	**/
	var ?type:String;

	/**
		Properties of a value that can be used to determine how to render the result in the UI.
	**/
	var ?presentationHint:VariablePresentationHint;

	/**
		If variablesReference is > 0, the value is structured and its children can be retrieved by passing variablesReference to the VariablesRequest.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?variablesReference:Int;

	/**
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?namedVariables:Int;

	/**
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?indexedVariables:Int;
}>;

/**
	StepInTargets request; value of command field is 'stepInTargets'.
	This request retrieves the possible stepIn targets for the specified stack frame.
	These targets can be used in the 'stepIn' request.
	The StepInTargets may only be called if the 'supportsStepInTargetsRequest' capability exists and is true.
	Clients should only call this request if the capability 'supportsStepInTargetsRequest' is true.
**/
typedef StepInTargetsRequest = Request<StepInTargetsArguments>;

/**
	Arguments for 'stepInTargets' request.
**/
typedef StepInTargetsArguments = {
	/**
		The stack frame for which to retrieve the possible stepIn targets.
	**/
	var frameId:Int;
}

/**
	Response to 'stepInTargets' request.
**/
typedef StepInTargetsResponse = Response<{
	/**
		The possible stepIn targets of the specified source location.
	**/
	var targets:Array<StepInTarget>;
}>;

/**
	GotoTargets request; value of command field is 'gotoTargets'.
	This request retrieves the possible goto targets for the specified source location.
	These targets can be used in the 'goto' request.
	Clients should only call this request if the capability 'supportsGotoTargetsRequest' is true.
**/
typedef GotoTargetsRequest = Request<GotoTargetsArguments>;

/**
	Arguments for 'gotoTargets' request.
**/
typedef GotoTargetsArguments = {
	/**
		The source location for which the goto targets are determined.
	**/
	var source:Source;

	/**
		The line location for which the goto targets are determined.
	**/
	var line:Int;

	/**
		An optional column location for which the goto targets are determined.
	**/
	var ?column:Int;
}

/**
	Response to 'gotoTargets' request.
**/
typedef GotoTargetsResponse = Response<{
	/**
		The possible goto targets of the specified location.
	**/
	var targets:Array<GotoTarget>;
}>;

/**
	Completions request; value of command field is 'completions'.
	Returns a list of possible completions for a given caret position and text.
	Clients should only call this request if the capability 'supportsCompletionsRequest' is true.
**/
typedef CompletionsRequest = Request<CompletionsArguments>;

/**
	Arguments for 'completions' request.
**/
typedef CompletionsArguments = {
	/**
		Returns completions in the scope of this stack frame. If not specified, the completions are returned for the global scope.
	**/
	var ?frameId:Int;

	/**
		One or more source lines. Typically this is the text a user has typed into the debug console before he asked for completion.
	**/
	var text:String;

	/**
		The character position for which to determine the completion proposals.
	**/
	var column:Int;

	/**
		An optional line for which to determine the completion proposals. If missing the first line of the text is assumed.
	**/
	var ?line:Int;
}

/**
	Response to 'completions' request.
**/
typedef CompletionsResponse = Response<{
	/**
		The possible completions for .
	**/
	var targets:Array<CompletionItem>;
}>;

/**
	ExceptionInfo request; value of command field is 'exceptionInfo'.
	Retrieves the details of the exception that caused this event to be raised.
	Clients should only call this request if the capability 'supportsExceptionInfoRequest' is true.
**/
typedef ExceptionInfoRequest = Request<ExceptionInfoArguments>;

/**
	Arguments for 'exceptionInfo' request.
**/
typedef ExceptionInfoArguments = {
	/**
		Thread for which exception information should be retrieved.
	**/
	var threadId:Int;
}

/**
	Response to 'exceptionInfo' request.
**/
typedef ExceptionInfoResponse = Response<{
	/**
		ID of the exception that was thrown.
	**/
	var exceptionId:String;

	/**
		Descriptive text for the exception provided by the debug adapter.
	**/
	var ?description:String;

	/**
		Mode that caused the exception notification to be raised.
	**/
	var breakMode:ExceptionBreakMode;

	/**
		Detailed information about the exception.
	**/
	var ?details:ExceptionDetails;
}>;

/**
	ReadMemory request; value of command field is 'readMemory'.
	Reads bytes from memory at the provided location.
	Clients should only call this request if the capability 'supportsReadMemoryRequest' is true.
**/
typedef ReadMemoryRequest = Request<ReadMemoryArguments>;

/**
	Arguments for 'readMemory' request.
**/
typedef ReadMemoryArguments = {
	/**
		Memory reference to the base location from which data should be read.
	**/
	var memoryReference:String;

	/**
		Optional offset (in bytes) to be applied to the reference location before reading data. Can be negative.
	**/
	var ?offset:Int;

	/**
		Number of bytes to read at the specified location and offset.
	**/
	var count:Int;
}

/**
	Response to 'readMemory' request.
**/
typedef ReadMemoryResponse = Response<{
	/**
		The address of the first byte of data returned.
		Treated as a hex value if prefixed with '0x', or as a decimal value otherwise.
	**/
	var address:String;

	/**
		The number of unreadable bytes encountered after the last successfully read byte.
		This can be used to determine the number of bytes that must be skipped before a subsequent 'readMemory' request will succeed.
	**/
	var ?unreadableBytes:Int;

	/**
		The bytes read from memory, encoded using base64.
	**/
	var ?data:String;
}>;

/**
	Disassemble request; value of command field is 'disassemble'.
	Disassembles code stored at the provided location.
	Clients should only call this request if the capability 'supportsDisassembleRequest' is true.
**/
typedef DisassembleRequest = Request<DisassembleArguments>;

/**
	Arguments for 'disassemble' request.
**/
typedef DisassembleArguments = {
	/**
		Memory reference to the base location containing the instructions to disassemble.
	**/
	var memoryReference:String;

	/**
		Optional offset (in bytes) to be applied to the reference location before disassembling. Can be negative.
	**/
	var ?offset:Int;

	/**
		Optional offset (in instructions) to be applied after the byte offset (if any) before disassembling. Can be negative.
	**/
	var ?instructionOffset:Int;

	/**
		Number of instructions to disassemble starting at the specified location and offset.
		An adapter must return exactly this number of instructions - any unavailable instructions should be replaced with an implementation-defined 'invalid instruction' value.
	**/
	var ?instructionCount:Int;

	/**
		If true, the adapter should attempt to resolve memory addresses and other values to symbolic names.
	**/
	var ?resolveSymbols:Bool;
}

/**
	Response to 'disassemble' request.
**/
typedef DisassembleResponse = Response<{
	/**
		The list of disassembled instructions.
	**/
	var instructions:Array<DisassembledInstruction>;
}>;

/**
	Information about the capabilities of a debug adapter.
**/
typedef Capabilities = {
	/**
		The debug adapter supports the configurationDoneRequest.
	**/
	var ?supportsConfigurationDoneRequest:Bool;

	/**
		The debug adapter supports function breakpoints.
	**/
	var ?supportsFunctionBreakpoints:Bool;

	/**
		The debug adapter supports conditional breakpoints.
	**/
	var ?supportsConditionalBreakpoints:Bool;

	/**
		The debug adapter supports breakpoints that break execution after a specified number of hits.
	**/
	var ?supportsHitConditionalBreakpoints:Bool;

	/**
		The debug adapter supports a (side effect free) evaluate request for data hovers.
	**/
	var ?supportsEvaluateForHovers:Bool;

	/**
		Available filters or options for the setExceptionBreakpoints request.
	**/
	var ?exceptionBreakpointFilters:Array<ExceptionBreakpointsFilter>;

	/**
		The debug adapter supports stepping back via the stepBack and reverseContinue requests.
	**/
	var ?supportsStepBack:Bool;

	/**
		The debug adapter supports setting a variable to a value.
	**/
	var ?supportsSetVariable:Bool;

	/**
		The debug adapter supports restarting a frame.
	**/
	var ?supportsRestartFrame:Bool;

	/**
		The debug adapter supports the gotoTargetsRequest.
	**/
	var ?supportsGotoTargetsRequest:Bool;

	/**
		The debug adapter supports the stepInTargetsRequest.
	**/
	var ?supportsStepInTargetsRequest:Bool;

	/**
		The debug adapter supports the completionsRequest.
	**/
	var ?supportsCompletionsRequest:Bool;

	/**
		The debug adapter supports the modules request.
	**/
	var ?supportsModulesRequest:Bool;

	/**
		The set of additional module information exposed by the debug adapter.
	**/
	var ?additionalModuleColumns:Array<ColumnDescriptor>;

	/**
		Checksum algorithms supported by the debug adapter.
	**/
	var ?supportedChecksumAlgorithms:Array<ChecksumAlgorithm>;

	/**
		The debug adapter supports the RestartRequest. In this case a client should not implement 'restart' by terminating and relaunching the adapter but by calling the RestartRequest.
	**/
	var ?supportsRestartRequest:Bool;

	/**
		The debug adapter supports 'exceptionOptions' on the setExceptionBreakpoints request.
	**/
	var ?supportsExceptionOptions:Bool;

	/**
		The debug adapter supports a 'format' attribute on the stackTraceRequest, variablesRequest, and evaluateRequest.
	**/
	var ?supportsValueFormattingOptions:Bool;

	/**
		The debug adapter supports the exceptionInfo request.
	**/
	var ?supportsExceptionInfoRequest:Bool;

	/**
		The debug adapter supports the 'terminateDebuggee' attribute on the 'disconnect' request.
	**/
	var ?supportTerminateDebuggee:Bool;

	/**
		The debug adapter supports the delayed loading of parts of the stack, which requires that both the 'startFrame' and 'levels' arguments and the 'totalFrames' result of the 'StackTrace' request are supported.
	**/
	var ?supportsDelayedStackTraceLoading:Bool;

	/**
		The debug adapter supports the 'loadedSources' request.
	**/
	var ?supportsLoadedSourcesRequest:Bool;

	/**
		The debug adapter supports logpoints by interpreting the 'logMessage' attribute of the SourceBreakpoint.
	**/
	var ?supportsLogPoints:Bool;

	/**
		The debug adapter supports the 'terminateThreads' request.
	**/
	var ?supportsTerminateThreadsRequest:Bool;

	/**
		The debug adapter supports the 'setExpression' request.
	**/
	var ?supportsSetExpression:Bool;

	/**
		The debug adapter supports the 'terminate' request.
	**/
	var ?supportsTerminateRequest:Bool;

	/**
		The debug adapter supports data breakpoints.
	**/
	var ?supportsDataBreakpoints:Bool;

	/**
		The debug adapter supports the 'readMemory' request.
	**/
	var ?supportsReadMemoryRequest:Bool;

	/**
		The debug adapter supports the 'disassemble' request.
	**/
	var ?supportsDisassembleRequest:Bool;

	/**
		The debug adapter supports the 'cancel' request.
	**/
	var ?supportsCancelRequest:Bool;

	/**
		The debug adapter supports the 'breakpointLocations' request.
	**/
	var ?supportsBreakpointLocationsRequest:Bool;

	/**
		The debug adapter supports the 'clipboard' context value in the 'evaluate' request.
	**/
	var ?supportsClipboardContext:Bool;

	/**
		The debug adapter supports stepping granularities (argument 'granularity') for the stepping requests.
	**/
	var ?supportsSteppingGranularity:Bool;

	/**
		The debug adapter supports adding breakpoints based on instruction references
	**/
	var ?supportsInstructionBreakpoints:Bool;
}

/**
	An ExceptionBreakpointsFilter is shown in the UI as an option for configuring how exceptions are dealt with.
**/
typedef ExceptionBreakpointsFilter = {
	/**
		The internal ID of the filter. This value is passed to the setExceptionBreakpoints request.
	**/
	var filter:String;

	/**
		The name of the filter. This will be shown in the UI.
	**/
	var label:String;

	/**
		Initial value of the filter. If not specified a value 'false' is assumed.
	**/
	// var ?default:Bool;
}

/**
	A structured message object. Used to return errors from requests.
**/
typedef Message = {
	/**
		Unique identifier for the message.
	**/
	var id:Int;

	/**
		A format string for the message. Embedded variables have the form '{name}'.
		If variable name starts with an underscore character, the variable does not contain user data (PII) and can be safely used for telemetry purposes.
	**/
	var format:String;

	/**
		An object used as a dictionary for looking up the variables in the format string.
	**/
	var ?variables:DynamicAccess<String>;

	/**
		If true send to telemetry.
	**/
	var ?sendTelemetry:Bool;

	/**
		If true show user.
	**/
	var ?showUser:Bool;

	/**
		An optional url where additional information about this message can be found.
	**/
	var ?url:String;

	/**
		An optional label that is presented to the user as the UI for opening the url.
	**/
	var ?urlLabel:String;
}

/**
	A Module object represents a row in the modules view.
	Two attributes are mandatory: an id identifies a module in the modules view and is used in a ModuleEvent for identifying a module for adding, updating or deleting.
	The name is used to minimally render the module in the UI.

	Additional attributes can be added to the module. They will show up in the module View if they have a corresponding ColumnDescriptor.

	To avoid an unnecessary proliferation of additional attributes with similar semantics but different names
	we recommend to re-use attributes from the 'recommended' list below first, and only introduce new attributes if nothing appropriate could be found.
**/
typedef Module = {
	/**
		Unique identifier for the module.
	**/
	var id:EitherType<Int, String>;

	/**
		A name of the module.
	**/
	var name:String;

	/**
		Logical full path to the module. The exact definition is implementation defined, but usually this would be a full path to the on-disk file for the module.
	**/
	var ?path:String;

	/**
		True if the module is optimized.
	**/
	var ?isOptimized:Bool;

	/**
		True if the module is considered 'user code' by a debugger that supports 'Just My Code'.
	**/
	var ?isUserCode:Bool;

	/**
		Version of Module.
	**/
	var ?version:String;

	/**
		User understandable description of if symbols were found for the module (ex: 'Symbols Loaded', 'Symbols not found', etc.
	**/
	var ?symbolStatus:String;

	/**
		Logical full path to the symbol file. The exact definition is implementation defined.
	**/
	var ?symbolFilePath:String;

	/**
		Module created or modified.
	**/
	var ?dateTimeStamp:String;

	/**
		Address range covered by this module.
	**/
	var ?addressRange:String;
}

enum abstract ColumnDescriptorType(String) {
	var String = "string";
	var Number = "number";
	var Boolean = "boolean";
	var UnixTimestampUTC = "unixTimestampUTC";
}

/**
	A ColumnDescriptor specifies what module attribute to show in a column of the ModulesView, how to format it,
	and what the column's label should be.
	It is only used if the underlying UI actually supports this level of customization.
**/
typedef ColumnDescriptor = {
	/**
		Name of the attribute rendered in this column.
	**/
	var attributeName:String;

	/**
		Header UI label of column.
	**/
	var label:String;

	/**
		Format to use for the rendered values in this column. TBD how the format strings looks like.
	**/
	var ?format:String;

	/**
		Datatype of values in this column.  Defaults to 'string' if not specified.
	**/
	var ?type:ColumnDescriptorType;

	/**
		Width of this column in characters (hint only).
	**/
	var ?width:Int;
}

/**
	The ModulesViewDescriptor is the container for all declarative configuration options of a ModuleView.
	For now it only specifies the columns to be shown in the modules view.
**/
typedef ModulesViewDescriptor = {
	var columns:Array<ColumnDescriptor>;
}

/**
	A Thread
**/
typedef Thread = {
	/**
		Unique identifier for the thread.
	**/
	var id:Int;

	/**
		A name of the thread.
	**/
	var name:String;
}

enum abstract SourcePresentationHint(String) {
	var Normal = 'normal';
	var Emphasize = 'emphasize';
	var Deemphasize = 'deemphasize';
}

/**
	A Source is a descriptor for source code.
	It is returned from the debug adapter as part of a StackFrame and it is used by clients when specifying breakpoints.
**/
typedef Source = {
	/**
		The short name of the source. Every source returned from the debug adapter has a name.
		When sending a source to the debug adapter this name is optional.
	**/
	var ?name:String;

	/**
		The path of the source to be shown in the UI.
		It is only used to locate and load the content of the source if no sourceReference is specified (or its value is 0).
	**/
	var ?path:String;

	/**
		If sourceReference > 0 the contents of the source must be retrieved through the SourceRequest (even if a path is specified).
		A sourceReference is only valid for a session, so it must not be used to persist a source.
		The value should be less than or equal to 2147483647 (2^31 - 1).
	**/
	var ?sourceReference:Int;

	/**
		An optional hint for how to present the source in the UI.
		A value of 'deemphasize' can be used to indicate that the source is not available or that it is skipped on stepping.
	**/
	var ?presentationHint:SourcePresentationHint;

	/**
		The (optional) origin of this source: possible values 'internal module', 'inlined content from source map', etc.
	**/
	var ?origin:String;

	/**
		An optional list of sources that are related to this source. These may be the source that generated this source.
	**/
	var ?sources:Array<Source>;

	/**
		Optional data that a debug adapter might want to loop through the client.
		The client should leave the data intact and persist it across sessions. The client should not interpret the data.
	**/
	var ?adapterData:Dynamic;

	/**
		The checksums associated with this file.
	**/
	var ?checksums:Array<Checksum>;
}

enum abstract StackFramePresentationHint(String) {
	var Normal = 'normal';

	/**
		A value of 'label' can be used to indicate that the frame is an artificial frame that is used as a visual label or separator.
	**/
	var Label = 'label';

	/**
		A value of 'subtle' can be used to change the appearance of a frame in a 'subtle' way.
	**/
	var Subtle = 'subtle';
}

/**
	A Stackframe contains the source location.
**/
typedef StackFrame = {
	/**
		An identifier for the stack frame. It must be unique across all threads.
		This id can be used to retrieve the scopes of the frame with the 'scopesRequest' or to restart the execution of a stackframe.
	**/
	var id:Int;

	/**
		The name of the stack frame, typically a method name.
	**/
	var name:String;

	/**
		The optional source of the frame.
	**/
	var ?source:Source;

	/**
		The line within the file of the frame. If source is null or doesn't exist, line is 0 and must be ignored.
	**/
	var line:Int;

	/**
		The column within the line. If source is null or doesn't exist, column is 0 and must be ignored.
	**/
	var column:Int;

	/**
		An optional end line of the range covered by the stack frame.
	**/
	var ?endLine:Int;

	/**
		An optional end column of the range covered by the stack frame.
	**/
	var ?endColumn:Int;

	/**
		The module associated with this frame, if any.
	**/
	var ?moduleId:EitherType<Int, String>;

	/**
		An optional hint for how to present this frame in the UI.
	**/
	var ?presentationHint:StackFramePresentationHint;
}

enum abstract ScopePresentationHint(String) from String {
	var Arguments = 'arguments';
	var Locals = 'locals';
	var Registers = 'registers';
}

/**
	A Scope is a named container for variables. Optionally a scope can map to a source or a range within a source.
**/
typedef Scope = {
	/**
		Name of the scope such as 'Arguments', 'Locals'.
	**/
	var name:String;

	/**
		An optional hint for how to present this scope in the UI. If this attribute is missing, the scope is shown with a generic UI.
		Values:
		'arguments': Scope contains method arguments.
		'locals': Scope contains local variables.
		'registers': Scope contains registers. Only a single 'registers' scope should be returned from a 'scopes' request.
		etc.
	**/
	var ?presentationHint:ScopePresentationHint;

	/**
		The variables of this scope can be retrieved by passing the value of variablesReference to the VariablesRequest.
	**/
	var variablesReference:Int;

	/**
		The number of named variables in this scope.
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
	**/
	var ?namedVariables:Int;

	/**
		The number of indexed variables in this scope.
		The client can use this optional information to present the variables in a paged UI and fetch them in chunks.
	**/
	var ?indexedVariables:Int;

	/**
		If true, the number of variables in this scope is large or expensive to retrieve.
	**/
	var expensive:Bool;

	/**
		Optional source for this scope.
	**/
	var ?source:Source;

	/**
		Optional start line of the range covered by this scope.
	**/
	var ?line:Int;

	/**
		Optional start column of the range covered by this scope.
	**/
	var ?column:Int;

	/**
		Optional end line of the range covered by this scope.
	**/
	var ?endLine:Int;

	/**
		Optional end column of the range covered by this scope.
	**/
	var ?endColumn:Int;
}

/**
	A Variable is a name/value pair.
	Optionally a variable can have a 'type' that is shown if space permits or when hovering over the variable's name.
	An optional 'kind' is used to render additional properties of the variable, e.g. different icons can be used to indicate that a variable is public or private.
	If the value is structured (has children), a handle is provided to retrieve the children with the VariablesRequest.
	If the number of named or indexed children is large, the numbers should be returned via the optional 'namedVariables' and 'indexedVariables' attributes.
	The client can use this optional information to present the children in a paged UI and fetch them in chunks.
**/
typedef Variable = {
	/**
		The variable's name.
	**/
	var name:String;

	/**
		The variable's value. This can be a multi-line text, e.g. for a function the body of a function.
	**/
	var value:String;

	/**
		The type of the variable's value. Typically shown in the UI when hovering over the value.
		This attribute should only be returned by a debug adapter if the client has passed the value true for the 'supportsVariableType' capability of the 'initialize' request.
	**/
	var ?type:String;

	/**
		Properties of a variable that can be used to determine how to render the variable in the UI.
	**/
	var ?presentationHint:VariablePresentationHint;

	/**
		Optional evaluatable name of this variable which can be passed to the 'EvaluateRequest' to fetch the variable's value.
	**/
	var ?evaluateName:String;

	/**
		If variablesReference is > 0, the variable is structured and its children can be retrieved by passing variablesReference to the VariablesRequest.
	**/
	var variablesReference:Int;

	/** 
		The number of named child variables.
		The client can use this optional information to present the children in a paged UI and fetch them in chunks.
	**/
	var ?namedVariables:Int;

	/**
		The number of indexed child variables.
		The client can use this optional information to present the children in a paged UI and fetch them in chunks.
	**/
	var ?indexedVariables:Int;

	/**
		Optional memory reference for the variable if the variable represents executable code, such as a function pointer.
		This attribute is only required if the client has passed the value true for the 'supportsMemoryReferences' capability of the 'initialize' request.
	**/
	var ?memoryReference:String;
}

enum abstract VariableKind(String) from String {
	/**
		Indicates that the object is a property.
	**/
	var Property = 'property';

	/**
		Indicates that the object is a method.
	**/
	var Method = 'method';

	/**
		Indicates that the object is a class.
	**/
	var Class = 'class';

	/**
		Indicates that the object is data.
	**/
	var Data = 'data';

	/**
		Indicates that the object is an event.
	**/
	var Event = 'event';

	/**
		Indicates that the object is a base class.
	**/
	var BaseClass = 'baseClass';

	/**
		Indicates that the object is an inner class.
	**/
	var InnerClass = 'innerClass';

	/**
		Indicates that the object is an interface.
	**/
	var Interface = 'interface';

	/**
		Indicates that the object is the most derived class.
	**/
	var MostDerivedClass = 'mostDerivedClass';

	/**
		Indicates that the object is virtual, that means it is a synthetic object introduced by the
		adapter for rendering purposes, e.g. an index range for large arrays.
	**/
	var Virtual = 'virtual';

	/**
		Indicates that a data breakpoint is registered for the object.
	**/
	var DataBreakpoint = 'dataBreakpoint';
}

enum abstract VariableAttribute(String) from String {
	/**
		Indicates that the object is static.
	**/
	var Static = 'static';

	/**
		Indicates that the object is a constant.
	**/
	var Constant = 'constant';

	/**
		Indicates that the object is read only.
	**/
	var ReadOnly = 'readOnly';

	/**
		Indicates that the object is a raw string.
	**/
	var RawString = 'rawString';

	/**
		Indicates that the object can have an Object ID created for it.
	**/
	var HasObjectId = 'hasObjectId';

	/**
		Indicates that the object has an Object ID associated with it.
	**/
	var CanHaveObjectId = 'canHaveObjectId';

	/**
		Indicates that the evaluation had side effects.
	**/
	var HasSideEffects = 'hasSideEffects';
}

enum abstract VariableVisibility(String) from String {
	var Public = 'public';
	var Private = 'private';
	var Protected = 'protected';
	var Internal = 'internal';
	var Final = 'final';
}

/**
	Optional properties of a variable that can be used to determine how to render the variable in the UI.
**/
typedef VariablePresentationHint = {
	/**
		The kind of variable. Before introducing additional values, try to use the listed values.
	**/
	var ?kind:VariableKind;

	/**
		Set of attributes represented as an array of strings. Before introducing additional values, try to use the listed values.
	**/
	var ?attributes:Array<VariableAttribute>;

	/**
		Visibility of variable. Before introducing additional values, try to use the listed values.
	**/
	var ?visibility:VariableVisibility;
}

/**
	Properties of a breakpoint location returned from the 'breakpointLocations' request.
**/
typedef BreakpointLocation = {
	/**
		Start line of breakpoint location.
	**/
	var line:Int;

	/**
		Optional start column of breakpoint location.
	**/
	var ?column:Int;

	/**
		Optional end line of breakpoint location if the location covers a range.
	**/
	var ?endLine:Int;

	/**
		Optional end column of breakpoint location if the location covers a range.
	**/
	var ?endColumn:Int;
}

/**
	Properties of a breakpoint passed to the setBreakpoints request.
**/
typedef SourceBreakpoint = {
	/**
		The source line of the breakpoint.
	**/
	var line:Int;

	/**
		An optional source column of the breakpoint.
	**/
	var ?column:Int;

	/**
		An optional expression for conditional breakpoints.
		It is only honored by a debug adapter if the capability 'supportsConditionalBreakpoints' is true.
	**/
	var ?condition:String;

	/**
		An optional expression that controls how many hits of the breakpoint are ignored.
		The backend is expected to interpret the expression as needed.
		The attribute is only honored by a debug adapter if the capability 'supportsHitConditionalBreakpoints' is true.
	**/
	var ?hitCondition:String;

	/**
		If this attribute exists and is non-empty, the backend must not 'break' (stop)
		but log the message instead. Expressions within {} are interpolated.
		The attribute is only honored by a debug adapter if the capability 'supportsLogPoints' is true.
	**/
	var ?logMessage:String;
}

/**
	Properties of a breakpoint passed to the setFunctionBreakpoints request.
**/
typedef FunctionBreakpoint = {
	/**
		The name of the function.
	**/
	var name:String;

	/**
		An optional expression for conditional breakpoints.
		It is only honored by a debug adapter if the capability 'supportsConditionalBreakpoints' is true.
	**/
	var ?condition:String;

	/**
		An optional expression that controls how many hits of the breakpoint are ignored.
		The backend is expected to interpret the expression as needed.
		The attribute is only honored by a debug adapter if the capability 'supportsHitConditionalBreakpoints' is true.
	**/
	var ?hitCondition:String;
}

/**
	This enumeration defines all possible access types for data breakpoints.
**/
enum abstract DataBreakpointAccessType(String) {
	var Read = 'read';
	var Write = 'write';
	var ReadWrite = 'readWrite';
}

/**
	Properties of a data breakpoint passed to the setDataBreakpoints request.
**/
typedef DataBreakpoint = {
	/**
		An id representing the data. This id is returned from the dataBreakpointInfo request.
	**/
	var dataId:String;

	/**
		The access type of the data.
	**/
	var ?accessType:DataBreakpointAccessType;

	/**
		An optional expression for conditional breakpoints.
	**/
	var ?condition:String;

	/**
		An optional expression that controls how many hits of the breakpoint are ignored.
		The backend is expected to interpret the expression as needed.
	**/
	var ?hitCondition:String;
}

/**
	Properties of a breakpoint passed to the setInstructionBreakpoints request
**/
typedef InstructionBreakpoint = {
	/**
		The instruction reference of the breakpoint.
		This should be a memory or instruction pointer reference from an EvaluateResponse, Variable, StackFrame, GotoTarget, or Breakpoint.
	**/
	var instructionReference:String;

	/**
		An optional offset from the instruction reference.
		This can be negative.
	**/
	var ?offset:Int;

	/**
		An optional expression for conditional breakpoints.
		It is only honored by a debug adapter if the capability 'supportsConditionalBreakpoints' is true.
	**/
	var ?condition:String;

	/**
		An optional expression that controls how many hits of the breakpoint are ignored.
		The backend is expected to interpret the expression as needed.
		The attribute is only honored by a debug adapter if the capability 'supportsHitConditionalBreakpoints' is true.
	**/
	var ?hitCondition:String;
}

/**
	Information about a Breakpoint created in setBreakpoints or setFunctionBreakpoints.
**/
typedef Breakpoint = {
	/**
		An optional unique identifier for the breakpoint.
	**/
	var ?id:Int;

	/**
		If true breakpoint could be set (but not necessarily at the desired location).
	**/
	var verified:Bool;

	/**
		An optional message about the state of the breakpoint.
		This is shown to the user and can be used to explain why a breakpoint could not be verified.
	**/
	var ?message:String;

	/**
		The source where the breakpoint is located.
	**/
	var ?source:Source;

	/**
		The start line of the actual range covered by the breakpoint.
	**/
	var ?line:Int;

	/**
		An optional start column of the actual range covered by the breakpoint.
	**/
	var ?column:Int;

	/**
		An optional end line of the actual range covered by the breakpoint.
	**/
	var ?endLine:Int;

	/**
		An optional end column of the actual range covered by the breakpoint.
		If no end line is given, then the end column is assumed to be in the start line.
	**/
	var ?endColumn:Int;

	/**
		An optional memory reference to where the breakpoint is set.
	**/
	var ?instructionReference:String;

	/**
		An optional offset from the instruction reference.
		This can be negative.
	**/
	var ?offset:Int;
}

/**
	The granularity of one 'step' in the stepping requests 'next', 'stepIn', 'stepOut', and 'stepBack'.
	'statement': The step should allow the program to run until the current statement has finished executing.
	The meaning of a statement is determined by the adapter and it may be considered equivalent to a line.
	For example 'for(int i = 0; i < 10; i++) could be considered to have 3 statements 'int i = 0', 'i < 10', and 'i++'.
	'line': The step should allow the program to run until the current source line has executed.
	'instruction': The step should allow one instruction to execute (e.g. one x86 instruction).
**/
enum abstract SteppingGranularity(String) from String {
	var Statement = "statement";
	var Line = "line";
	var Instruction = "instruction";
}

/**
	A StepInTarget can be used in the 'stepIn' request and determines into which single target the stepIn request should step.
**/
typedef StepInTarget = {
	/**
		Unique identifier for a stepIn target.
	**/
	var id:Int;

	/**
		The name of the stepIn target (shown in the UI).
	**/
	var label:String;
}

/**
	A GotoTarget describes a code location that can be used as a target in the 'goto' request.
	The possible goto targets can be determined via the 'gotoTargets' request.
**/
typedef GotoTarget = {
	/**
		Unique identifier for a goto target. This is used in the goto request.
	**/
	var id:Int;

	/**
		The name of the goto target (shown in the UI).
	**/
	var label:String;

	/**
		The line of the goto target.
	**/
	var line:Int;

	/**
		An optional column of the goto target.
	**/
	var ?column:Int;

	/**
		An optional end line of the range covered by the goto target.
	**/
	var ?endLine:Int;

	/**
		An optional end column of the range covered by the goto target.
	**/
	var ?endColumn:Int;

	/**
		Optional memory reference for the instruction pointer value represented by this target.
	**/
	var ?instructionPointerReference:String;
}

/**
	CompletionItems are the suggestions returned from the CompletionsRequest.
**/
typedef CompletionItem = {
	/**
		The label of this completion item. By default this is also the text that is inserted when selecting this completion.
	**/
	var label:String;

	/**
		If text is not falsy then it is inserted instead of the label.
	**/
	var ?text:String;

	/**
		A string that should be used when comparing this item with other items. When `falsy` the label is used.
	**/
	var ?sortText:String;

	/**
		The item's type. Typically the client uses this information to render the item in the UI with an icon.
	**/
	var ?type:CompletionItemType;

	/**
		This value determines the location (in the CompletionsRequest's 'text' attribute) where the completion text is added.
		If missing the text is added at the location specified by the CompletionsRequest's 'column' attribute.
	**/
	var ?start:Int;

	/**
		This value determines how many characters are overwritten by the completion text.
		If missing the value 0 is assumed which results in the completion text being inserted.
	**/
	var ?length:Int;

	/**
		Determines the start of the new selection after the text has been inserted (or replaced).
		The start position must in the range 0 and length of the completion text.
		If omitted the selection starts at the end of the completion text.
	**/
	var ?selectionStart:Int;

	/**
		Determines the length of the new selection after the text has been inserted (or replaced).
		The selection can not extend beyond the bounds of the completion text.
		If omitted the length is assumed to be 0.
	**/
	var ?selectionLength:Int;
}

/**
	Some predefined types for the CompletionItem. Please note that not all clients have specific icons for all of them.
**/
enum abstract CompletionItemType(String) from String {
	var Method = "method";
	var Function = "function";
	var Constructor = "constructor";
	var Field = "field";
	var Variable = "variable";
	var Class = "class";
	var Interface = "interface";
	var Module = "module";
	var Property = "property";
	var Unit = "unit";
	var Value = "value";
	var Enum = "enum";
	var Keyword = "keyword";
	var Snippet = "snippet";
	var Text = "text";
	var Color = "color";
	var File = "file";
	var Reference = "reference";
	var CustomColor = "customcolor";
}

/**
	Names of checksum algorithms that may be supported by a debug adapter.
**/
enum abstract ChecksumAlgorithm(String) {
	var MD5 = 'MD5';
	var SHA1 = 'SHA1';
	var SHA256 = 'SHA256';
	var Timestamp = 'timestamp';
}

/**
	The checksum of an item calculated by the specified algorithm.
**/
typedef Checksum = {
	/**
		The algorithm used to calculate this checksum.
	**/
	var algorithm:ChecksumAlgorithm;

	/**
		Value of the checksum.
	**/
	var checksum:String;
}

/**
	Provides formatting information for a value.
**/
typedef ValueFormat = {
	/**
		Display the value in hex.
	**/
	var ?hex:Bool;
}

/**
	Provides formatting information for a stack frame.
**/
typedef StackFrameFormat = ValueFormat & {
	/**
		Displays parameters for the stack frame.
	**/
	var ?parameters:Bool;

	/**
		Displays the types of parameters for the stack frame.
	**/
	var ?parameterTypes:Bool;

	/**
		Displays the names of parameters for the stack frame.
	**/
	var ?parameterNames:Bool;

	/**
		Displays the values of parameters for the stack frame.
	**/
	var ?parameterValues:Bool;

	/**
		Displays the line number of the stack frame.
	**/
	var ?line:Bool;

	/**
		Displays the module of the stack frame.
	**/
	var ?module:Bool;

	/**
		Includes all stack frames, including those the debug adapter might otherwise hide.
	**/
	var ?includeAll:Bool;
}

/**
	An ExceptionOptions assigns configuration options to a set of exceptions.
**/
typedef ExceptionOptions = {
	/**
		A path that selects a single or multiple exceptions in a tree. If 'path' is missing, the whole tree is selected.
		By convention the first segment of the path is a category that is used to group exceptions in the UI.
	**/
	var ?path:Array<ExceptionPathSegment>;

	/**
		Condition when a thrown exception should result in a break.
	**/
	var breakMode:ExceptionBreakMode;
}

/**
	This enumeration defines all possible conditions when a thrown exception should result in a break.
**/
enum abstract ExceptionBreakMode(String) {
	/**
		never breaks
	**/
	var Never = 'never';

	/**
		always breaks
	**/
	var Always = 'always';

	/**
		breaks when exception unhandled
	**/
	var Unhandled = 'unhandled';

	/**
		breaks if the exception is not handled by user code.
	**/
	var UserUnhandled = 'userUnhandled';
}

/**
	An ExceptionPathSegment represents a segment in a path that is used to match leafs or nodes in a tree of exceptions.
	If a segment consists of more than one name, it matches the names provided if 'negate' is false or missing or
	it matches anything except the names provided if 'negate' is true.
**/
typedef ExceptionPathSegment = {
	/**
		If false or missing this segment matches the names provided, otherwise it matches anything except the names provided.
	**/
	var ?negate:Bool;

	/**
		Depending on the value of 'negate' the names that should match or not match.
	**/
	var names:Array<String>;
}

/**
	Detailed information about an exception that has occurred.
**/
typedef ExceptionDetails = {
	/**
		Message contained in the exception.
	**/
	var ?message:String;

	/**
		Short type name of the exception object.
	**/
	var ?typeName:String;

	/**
		Fully-qualified type name of the exception object.
	**/
	var ?fullTypeName:String;

	/**
		Optional expression that can be evaluated in the current scope to obtain the exception object.
	**/
	var ?evaluateName:String;

	/**
		Stack trace at the time the exception was thrown.
	**/
	var ?stackTrace:String;

	/**
		Details of the exception contained by this exception, if any.
	**/
	var ?innerException:Array<ExceptionDetails>;
}

/**
	Represents a single disassembled instruction.
**/
typedef DisassembledInstruction = {
	/**
		The address of the instruction. Treated as a hex value if prefixed with '0x', or as a decimal value otherwise.
	**/
	var address:String;

	/**
		Optional raw bytes representing the instruction and its operands, in an implementation-defined format.
	**/
	var ?instructionBytes:String;

	/**
		Text representing the instruction and its operands, in an implementation-defined format.
	**/
	var instruction:String;

	/**
		Name of the symbol that corresponds with the location of this instruction, if any.
	**/
	var ?symbol:String;

	/**
		Source location that corresponds to this instruction, if any.
		Should always be set (if available) on the first instruction returned,
		but can be omitted afterwards if this instruction maps to the same source file as the previous instruction.
	**/
	var ?location:Source;

	/**
		The line within the source location that corresponds to this instruction, if any.
	**/
	var ?line:Int;

	/**
		The column within the line that corresponds to this instruction, if any.
	**/
	var ?column:Int;

	/**
		The end line of the range that corresponds to this instruction, if any.
	**/
	var ?endLine:Int;

	/**
		The end column of the range that corresponds to this instruction, if any.
	**/
	var ?endColumn:Int;
}
