module.exports = class LocalLlamaCppProvider {
  constructor(options) {
    this.providerId = options.id || 'local-llamacpp';
    this.config = options.config || {};
  }

  id() {
    return this.providerId;
  }

  resolveConfigValue(configKey, defaultEnvKey) {
    const envKey = this.config[`${configKey}_env`] || defaultEnvKey;

    if (envKey && process.env[envKey]) {
      return process.env[envKey];
    }

    return this.config[configKey];
  }

  async callApi(prompt) {
    const baseUrl = (this.resolveConfigValue('base_url', 'LOCAL_LLAMACPP_BASE_URL') || 'http://localhost:8080').replace(
      /\/$/,
      '',
    );
    const model = this.resolveConfigValue('model', 'LOCAL_LLAMACPP_MODEL');
    const promptText = typeof prompt === 'string' ? prompt.trim() : '';

    let messages;
    if (promptText.startsWith('[')) {
      try {
        messages = JSON.parse(promptText);
      } catch (err) {
        messages = [{ role: 'user', content: promptText }];
      }
    } else {
      messages = [{ role: 'user', content: promptText }];
    }

    const payload = {
      messages,
      temperature: this.config.temperature ?? 0,
      max_tokens: this.config.max_tokens ?? 128,
    };

    if (model) {
      payload.model = model;
    }

    const response = await fetch(`${baseUrl}/v1/chat/completions`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      return {
        error: `HTTP ${response.status}: ${await response.text()}`,
      };
    }

    const data = await response.json();
    const message = data?.choices?.[0]?.message || {};

    return {
      output: message.content || '',
      tokenUsage: data?.usage
        ? {
            total: data.usage.total_tokens,
            prompt: data.usage.prompt_tokens,
            completion: data.usage.completion_tokens,
          }
        : undefined,
    };
  }
};
