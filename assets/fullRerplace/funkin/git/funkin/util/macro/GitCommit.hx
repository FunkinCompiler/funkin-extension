package funkin.util.macro;

#if !display
@:nullSafety
class GitCommit
{
  /**
   * Get the SHA1 hash of the current Git commit.
   */
  public static macro function getGitCommitHash():haxe.macro.Expr.ExprOf<String>
  {
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call git on every hint.
    var commitHash:String = "";
    return macro $v{commitHash};
  }

  /**
   * Get the branch name of the current Git commit.
   */
  public static macro function getGitBranch():haxe.macro.Expr.ExprOf<String>
  {
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call git on every hint.
    var branchName:String = "";
    return macro $v{branchName};
  }

  /**
   * Get whether the local Git repository is dirty or not.
   */
  public static macro function getGitHasLocalChanges():haxe.macro.Expr.ExprOf<Bool>
  {
    // `#if display` is used for code completion. In this case we just assume true.
    return macro $v{true};
  }
}
#end
