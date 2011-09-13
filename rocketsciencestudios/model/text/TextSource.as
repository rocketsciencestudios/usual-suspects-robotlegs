package rocketsciencestudios.model.text {
	import com.greensock.loading.LoaderMax;

	import flash.utils.Dictionary;

	/**
	 * @author Ralph Kuijpers @ Rocket Science Studios
	 */
	public class TextSource {
		public static const PRELOAD_NAME : String = "TEXT";
		public static var TextSourceClass : Class = TextSource;
		//
		private static var _instance : TextSource;
		//
		private var _textById : Dictionary;
		private var _debug : Boolean;

		public static function get instance() : TextSource {
			if (!_instance) {
				var untyped : * = new TextSourceClass();
				if (!(untyped is TextSource)) {
					throw new Error("Custom class must extend TextSourceSingle. This one does not: " + TextSourceClass);
				}
				_instance = untyped;
			}

			return _instance;
		}

		public function TextSource(debugMode : Boolean = false) {
			_debug = debugMode;
			_textById = new Dictionary();
		}

		public function getTextById(id : String) : String {
			if (_debug && !_textById[id]) {
				var d : TextVO = new TextVO();
				d.id = id;
				d.text = "tx@" + id;
				_textById[id] = d;
			}

			var text : TextVO = _textById[id] as TextVO;
			if (text) {
				return text.text;
			}

			return "#" + id + "#";
		}

		public function logDebugIDs() : void {
			var sorted : Array = [];

			for each (var t : TextVO in _textById) {
				sorted.push(t);
			}

			sorted.sortOn("id");
			debug(sorted.join("\n"));
		}

		public function initialize() : void {
			parseXML(LoaderMax.getContent(PRELOAD_NAME));
		}

		private function parseXML(inXML : XML) : void {
			for each (var node : XML in inXML.text) {
				var text : TextVO = new TextVO();
				text.parseXML(node);
				_textById[text.id] = text;
			}
		}
	}
}
