package rocketsciencestudios.model.text {
	/**
	 * @author Ralph Kuijpers @ Rocket Science Studios
	 */
	public function getText(id : String) : String {
		return TextSource.instance.getTextById(id);
	}
}
