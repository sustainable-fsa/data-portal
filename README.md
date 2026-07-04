# data-portal

The file explorer served at **<https://data.sustainable-fsa.com>** — raw file
access to the [Sustainable FSA](https://sustainable-fsa.com) project's public
data archives. Dataset descriptions and documentation live in the
[data catalog](https://sustainable-fsa.com/data/); this portal is only for
browsing and downloading the files themselves.

## How it works

- The archives live in the public S3 bucket `sustainable-fsa` (us-west-2),
  fronted by CloudFront distribution `E1BNL6ONVN84RI` with an Origin Access
  Control. The distribution serves `index.html` (this app) as its default
  root object.
- The app is a single self-contained HTML file. In the browser it calls S3's
  public `ListObjectsV2` API directly (the bucket allows anonymous
  `s3:ListBucket` and has a permissive CORS policy) and renders prefixes as
  folders. Downloads and Copy-URL actions go through the CloudFront domain.
- Navigation is hash-based (`#/<prefix>/`), so no CloudFront URL rewriting is
  needed.

### Key encoding

Object keys in these archives contain **literal spaces** and **literal `%`**
characters (Apache Arrow percent-encodes hive partition *values* when writing,
e.g. `State FSA Name=American%20Samoa`). When building URLs the app encodes
`%` first (`%25`), then spaces (`%20`), and leaves `=` and `/` literal —
keeping `=` literal matters because DuckDB's `hive_partitioning` detection
parses `key=value` from the raw URL path.

### Portal files in the bucket

`index.html`, `sustainable-fsa-banner.svg`, and `MCO_logo.svg` live at the
bucket root and are hidden from listings by the `PORTAL_FILES` set in
`index.html`. Everything else at the root is treated as a data prefix and
appears in the explorer automatically.

## Deploy

```sh
./deploy.sh            # AWS_PROFILE defaults to "mco"
```

Copies `index.html` and the brand assets to the bucket root and invalidates
`/` and `/index.html` on CloudFront. The brand SVGs under `assets/` are copies
of the ones in
[sustainable-fsa.github.io](https://github.com/sustainable-fsa/sustainable-fsa.github.io)
— if the site's branding changes, refresh them from there.

## License

MIT © R. Kyle Bocinsky. Part of *Enhancing Sustainable Disaster Relief in FSA
Programs*, supported by USDA OCE/OEEP and the USDA Climate Hubs; maintained by
the [Montana Climate Office](https://climate.umt.edu), University of Montana.
