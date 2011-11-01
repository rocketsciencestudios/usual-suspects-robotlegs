package rocketsciencestudios.model.environment {
	import nl.rocketsciencestudios.RSSVersion;

	import com.greensock.loading.LoaderMax;

	import org.robotlegs.mvcs.Actor;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;

	/**
	 * @author Ralph Kuijpers @ Rocket Science Studios
	 */
	public class EnvironmentModel extends Actor {
		public static const PRELOAD_NAME : String = "ENVIRONMENT";
		private static const LOCALHOST : String = "localhost";
		// 2
		private var _timeline : DisplayObject;
		private var _loaderURL : String;
		private var _environment : Dictionary;
		private var _versionHash : String;
		private var _domain : String;

		public function EnvironmentModel(timeline : DisplayObjectContainer) {
			_timeline = timeline;
			_environment = new Dictionary();
			_loaderURL = _timeline.loaderInfo.loaderURL;
			parseXML(LoaderMax.getContent(PRELOAD_NAME));
		}

		public function get domain() : String {
			return _domain;
		}

		public function getValueByName(name : String, appendVariables : Object = null) : String {
			var value : EnvironmentValueVO = _environment[name] as EnvironmentValueVO;

			if (!value) {
				error("getValueByName value not set for: " + name);
				return "";
			}

			if (!value.isURL) {
				info("Returning non-url value");
				return value.value;
			}

			var suffix : String = "";

			if (appendVariables) {
				for (var key : String in appendVariables) {
					suffix += key + "=" + escape(appendVariables[key]) + "&";
				}
				suffix = suffix.substring(0, suffix.length - 1);
			}

			if (value.hashCompatible) {
				suffix += _versionHash;
			}

			return value.suffixURL(suffix);
		}

		public function getURLRequestByName(name : String, appendVariables : Object = null) : URLRequest {
			var url : String = getValueByName(name, appendVariables);
			if (url == "") return null;

			return new URLRequest(url);
		}

		public function getParameterByName(inName : String) : String {
			if (_timeline == null)
				return null;
			return _timeline.loaderInfo.parameters[inName];
		}

		public function navigateToByName(name : String, window : String = "_blank", appendVariables : Object = null) : void {
			var request : URLRequest = new URLRequest(getValueByName(name, appendVariables));
			navigateToURL(request, window);
		}

		private function parseXML(xml : XML) : void {
			var environment : XML = xml;
			var filteredValues : XML = <values />;

			// Values outside of <group> tags are shared in all environments:
			var sharedValues : XMLList = environment.value;
			if (sharedValues && sharedValues.length()) {
				filteredValues.appendChild(sharedValues);
			}

			// Values within <group> tags are only used if the group corresponds with the required mode:
			_domain = getEnvironmentDomain();
			var groupedValues : XMLList = getGroupedValues(environment.group, _domain);

			if (groupedValues.length()) {
				filteredValues.appendChild(groupedValues);
			}

			var values : XMLList = filteredValues.children();
			for each (var valueNode : XML in values) {
				var value : EnvironmentValueVO = new EnvironmentValueVO();
				value.parseXML(valueNode);
				_environment[value.name] = value;
			}
		}

		private function getGroupedValues(inGroups : XMLList, inDomain : String) : XMLList {
			debug("inDomain: " + inDomain);
			if (!inGroups)
				return null;

			var groupedValues : XMLList;
			debug("groupedValues: " + groupedValues);
			var localhost : XMLList;

			var leni : int = inGroups.length();
			for (var i : int = 0; i < leni ; i++) {
				var group : XML = inGroups[i] as XML;
				var domains : Array = String(group.@domain).split(",");
				for each (var domain : String in domains) {
					if (domain == inDomain) {
						info(RSSVersion.HASH + " Using environment domain [" + domains + "] in " + _loaderURL);
						groupedValues = group.value;
						break;
					} else if (domain == LOCALHOST) {
						localhost = group.value;
					}
				}
			}

			if (!groupedValues) {
				warn("Could not find a group for domain [" + domain + "], defaulting to [" + LOCALHOST + "] in " + _loaderURL);
				groupedValues = localhost;
			}

			return groupedValues;
		}

		private function getEnvironmentDomain() : String {
			if (!new RegExp("^http:/{2}", "i").test(_loaderURL))
				return LOCALHOST;

			var domain : RegExp = new RegExp("http:\/\/(?:www\.)?([^\/]+)", "i");
			var result : Array = _loaderURL.match(domain);

			return result[1];
		}
	}
}
