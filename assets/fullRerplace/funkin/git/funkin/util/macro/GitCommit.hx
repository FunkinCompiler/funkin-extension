package funkin.util.macro;

#if !display
@:nullSafety
class GitCommit
{
  /**
   * Get the SHA1 hash of the current Git commit.
   */
  public static function getGitCommitHash():String
  {
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call git on every hint.
    var commitHash:String = "";
    return "";
  }

  /**
   * Get the branch name of the current Git commit.
   */
  public static function getGitBranch():String
  {
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call git on every hint.
    return "";
  }

  /**
   * Get whether the local Git repository is dirty or not.
   */
  public static function getGitHasLocalChanges():Bool
  {
    // `#if display` is used for code completion. In this case we just assume true.
    return true;
  }
}
#end
