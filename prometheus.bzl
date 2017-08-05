# Apply a patch_file to the repository root directory
# Runs 'patch -p1'
def _execute_and_check_ret_code(repo_ctx, cmd_and_args):
  result = repo_ctx.execute(cmd_and_args, timeout=10)
  if result.return_code != 0:
    fail(("Non-zero return code({1}) when executing '{0}':\n" + "Stdout: {2}\n"
          + "Stderr: {3}").format(" ".join(cmd_and_args), result.return_code,
                                  result.stdout, result.stderr))
                                  
def _apply_patch(repo_ctx, patch_file):
  cmd = [
      "patch", "-p1", "-d", repo_ctx.path("."), "-i", repo_ctx.path(patch_file)
  ]
  _execute_and_check_ret_code(repo_ctx, cmd)

def _patched_http_archive_impl(repo_ctx):
  repo_ctx.download_and_extract(
      repo_ctx.attr.urls,
      sha256=repo_ctx.attr.sha256,
      stripPrefix=repo_ctx.attr.strip_prefix)
  _apply_patch(repo_ctx, repo_ctx.attr.patch_file)


patched_http_archive = repository_rule(
    implementation = _patched_http_archive_impl,
    attrs = {
        "patch_file": attr.label(),
        "build_file": attr.label(),
        "repository": attr.string(),
        "urls": attr.string_list(default = []),
        "sha256": attr.string(default = ""),
        "strip_prefix": attr.string(default = ""),
    },
)

def prometheus_workspace(path_prefix="", tf_repo_name=""):
  patched_http_archive(
      name = "protobuf",
      urls = [
          "https://github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz",
          "http://mirror.bazel.build/github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz",
      ],
      sha256 = "6d43b9d223ce09e5d4ce8b0060cb8a7513577a35a64c7e3dad10f0703bf3ad93",
      strip_prefix = "protobuf-0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66",
      # TODO: remove patching when tensorflow stops linking same protos into
      #       multiple shared libraries loaded in runtime by python.
      #       This patch fixes a runtime crash when tensorflow is compiled
      #       with clang -O2 on Linux (see https://github.com/tensorflow/tensorflow/issues/8394)
      patch_file = str(Label("//third_party/protobuf:add_noinlines.patch")),
  )

  native.http_archive(
      name = "com_google_protobuf",
      urls = [
          "https://github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz",
          "http://mirror.bazel.build/github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz",
      ],
      sha256 = "6d43b9d223ce09e5d4ce8b0060cb8a7513577a35a64c7e3dad10f0703bf3ad93",
      strip_prefix = "protobuf-0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66",
  )

  native.http_archive(
      name = "com_google_protobuf_cc",
      urls = [
          "https://github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz",
          "http://mirror.bazel.build/github.com/google/protobuf/archive/0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66.tar.gz",
      ],
      sha256 = "6d43b9d223ce09e5d4ce8b0060cb8a7513577a35a64c7e3dad10f0703bf3ad93",
      strip_prefix = "protobuf-0b059a3d8a8f8aa40dde7bea55edca4ec5dfea66",
  )

  native.new_http_archive(
      name = "gmock_archive",
      urls = [
          "http://mirror.bazel.build/github.com/google/googletest/archive/release-1.8.0.zip",
          "https://github.com/google/googletest/archive/release-1.8.0.zip",
      ],
      sha256 = "f3ed3b58511efd272eb074a3a6d6fb79d7c2e6a0e374323d1e6bcbcc1ef141bf",
      strip_prefix = "googletest-release-1.8.0",
      build_file = str(Label("//third_party:gmock.BUILD")),
  )

  native.bind(
      name = "gtest",
      actual = "@gmock_archive//:gtest",
  )

  native.bind(
      name = "gtest_main",
      actual = "@gmock_archive//:gtest_main",
  )