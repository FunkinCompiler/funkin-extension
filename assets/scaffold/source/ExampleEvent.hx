package mikolka;

import funkin.data.event.SongEventSchema;
import funkin.play.event.SongEvent;

class ExampleEvent extends SongEvent
{
  public function new()
  {
    super("test47");
  }

  override function getEventSchema():SongEventSchema
  {
    return [
      {
        name: "stringVal", // The name of the property (for use in event data)
        title: "String 1", // The title to display in the charter
        type: "string", // type of a field.
        defaultValue: "", // A default value for it
      },
      { //? Don't worry about errors. Funkin Compiler isn't perfect and *may* see errors in the valid code
        name: "IsFunky", // The name of the property (for use in event data)
        title: "Do you get freaky?", // The title to display in the charter
        type: "bool", // type of a field.
        defaultValue: true, // A default value for it
      },
      {
        name: "lt", // The name of the property (for use in event data)
        title: "How many BFs you want?", // The title to display in the charter
        type: "float", // type of a field.
        defaultValue: 0.5, // A default value for it
        max: 1.1,
        min: 0,
        step: 0.1
      },
      {
        name: "lt", // The name of the property (for use in event data)
        title: "How many BFs you want?", // The title to display in the charter
        type: "integer", // type of a field.
        defaultValue: 0, // A default value for it
        max: 2,
        min: 0,
        step: 1
      },
      {
        name: "NUm", // The name of the property (for use in event data)
        title: "Pick a number..", // The title to display in the charter
        type: "enum", // type of a field.
        keys: ["one" => 1, "two" => 2, "three" => 3],
        defaultValue: 2, // A default value for it
      }
    ];
  }
}
