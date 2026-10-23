exports.handler = (event, context, callback) => {
    const requestHeaders = event.Records[0].cf.request.headers;

    let str = '<table border="1" width="100%">' +
              '<thead>' +
                '<tr><td><h1>Header</h1></td><td><h1>Value</h1></td></tr>' +
              '</thead>' +
              '<tbody>';

    for (const key in requestHeaders) {
      if (requestHeaders.hasOwnProperty(key)) {
        str += '<tr><td>' + key + '</td><td>' + requestHeaders[key][0].value + '</td></tr>';
      }
    }

    str += '</tbody></table>';

    const htmlContent = `
      <html lang="en">
        <body>
          <table border="1" width="100%">
            <thead>
              <tr><td><h1>Lambda@Edge Lab</h1></td></tr>
            </thead>
            <tfoot>
              <tr><td>Immersion Days - Edge Services - Module 3</td></tr>
            </tfoot>
            <tbody>
              <tr><td>Response sent by API</td></tr>
            </tbody>
            <tbody>
              <tr><td>${str}</td></tr>
            </tbody>
          </table>
        </body>
      </html>
    `;

    const response = {
      status: '200',
      statusDescription: 'OK',
      headers: {
        'cache-control': [{ key: 'Cache-Control', value: 'max-age=100' }],
        'content-type': [{ key: 'Content-Type', value: 'text/html' }],
        'content-encoding': [{ key: 'Content-Encoding', value: 'UTF-8' }],
      },
      body: htmlContent,
    };

    callback(null, response);
  };
