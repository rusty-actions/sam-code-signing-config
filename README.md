# sam-code-signing-config <br/>![gh-test-status]![gh-release-status]

A GitHub Action to auto generate SAM code signing config from a SAM template.

# Auto code signing config action

This action finds lambda functions in a SAM template and generates a code signing script block to sign them.

## Inputs

## `template`

**Required** The path to the SAM template. Default `"./template.yaml"`.

## `profile`

**Required** The profile name to use in the signing.

## `signer`

**Optional** A versioned siginer arn to be injected into the template for the code signing.

## Outputs

## `signing_profiles`

A script block to be used in sam package or sam deploy.

## Example usage without injecting the signer

```
- name: Generate code signing config
  id: signing
  uses: rusty-actions/sam-code-signing-config@v1
  with:
    template: ./template.yaml
    profile: ${{ secrets.SIGNING_PROFILE }}

- run: |
    sam deploy \
      ${{ steps.signing.outputs.signing_config }} \
      --no-fail-on-empty-changeset --debug
```

## Example usage with injecting the signer

```
- name: Generate code signing config
  id: signing
  uses: rusty-actions/sam-code-signing-config@v1
  with:
    template: ./template.yaml
    profile: ${{ secrets.SIGNING_PROFILE }}
    signer: ${{ secrets.SIGNING_VERSIONED_ARN }}


- run: |
    sam package --region ${{ env.AWS_REGION }} \
      --s3-bucket ${{ secrets.AWS_BUCKET_NAME }} \
      --s3-prefix sam-java-test \
      ${{ steps.signing.outputs.signing_config }}
```

<!-- Badge links -->

[gh-test-status]: https://github.com/rusty-actions/sam-code-signing-config/actions/workflows/test.yml/badge.svg
[gh-release-status]: https://github.com/rusty-actions/sam-code-signing-config/actions/workflows/release.yml/badge.svg
