package runner.server;
import js.node.Buffer;
import js.node.net.Socket;
import js.node.stream.Readable.ReadableEvent;

class Connection {
	final socket:Socket;

	var buffer:Buffer;
	var index:Int;

	var nextMessageLength:Int;
	var pending:Map<Int, Message->Void> = [];


	static inline final DEFAULT_BUFFER_SIZE = 4096;

	public function new(socket) {
		this.socket = socket;
		buffer = Buffer.alloc(DEFAULT_BUFFER_SIZE);
		index = 0;
		nextMessageLength = -1;
		
		socket.on(ReadableEvent.Data, onData);
	}

	function append(data:Buffer) {
		// append received data to the buffer, increasing it if needed
		if (buffer.length - index >= data.length) {
			data.copy(buffer, index, 0, data.length);
		} else {
			// copied from the language-server protocol reader
			final newSize = (Math.ceil((index + data.length) / DEFAULT_BUFFER_SIZE) + 1) * DEFAULT_BUFFER_SIZE;
			if (index == 0) {
				buffer = Buffer.alloc(newSize);
				data.copy(buffer, 0, 0, data.length);
			} else {
				buffer = Buffer.concat([buffer.slice(0, index), data], newSize);
			}
		}
		index += data.length;
	}

	function onData(data:Buffer) {
		// trace("Got data");
		append(data);
		while (true) {
			if (nextMessageLength == -1) {
				if (index < 4)
					return; // not enough data
				nextMessageLength = buffer.readInt16BE(0);
				
				index -= 2;
				buffer.copy(buffer, 0, 2);
				// trace(buffer.toString());
			}
			if (index < nextMessageLength)
				return;
			final bytes = buffer.toString("utf-8", 0, nextMessageLength);
			buffer.copy(buffer, 0, nextMessageLength);

			index -= nextMessageLength;
			nextMessageLength = -1;

			// trace('Received response: $bytes');
			final json = haxe.Json.parse(bytes);
			onMessage(json);
		}
	}

	public dynamic function onEvent(event:Message) {}

	public dynamic function onMessage(event:Message) {
		if (event.id != null && pending.exists(event.id)) {
			final cb = pending.get(event.id);
			pending.remove(event.id);
			cb(event);
			return;
		}
		onEvent(event);
	}
	var nextRequestId = 1;

	public function sendCommand(event:Message, ?callback:Message->Void) {
		final id = nextRequestId++;
		event.id = id;

		if (callback != null)
			pending.set(id, callback);

		final cmd = haxe.Json.stringify(event);
		trace('Sending command: $cmd');

		final body = Buffer.from(cmd, "utf-8");
		final header = Buffer.alloc(2);
		header.writeUInt16BE(body.length, 0);

		socket.write(Buffer.concat([header,body]));
	}

	public function close() {
		socket.end();
        socket.destroy();
	}
}
