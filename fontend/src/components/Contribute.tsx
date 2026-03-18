import clsx from "clsx";
import { useState } from "react";

type Props = {
  show: boolean;
  handleContribute: (value: string) => void;
};

export function Contribute({ show, handleContribute }: Props) {
  const [value, setValue] = useState("");
  const [loading, setLoading] = useState(false);
  return (
    <dialog className={clsx("modal", { "modal-open": show })}>
      <div className="modal-box">
        <h3 className="font-bold text-lg">赞助</h3>
        <form className="mt-4">
          <legend>贡献金额:</legend>
          <input
            type="number"
            step={0.01}
            min={0}
            className="input"
            value={value}
            onChange={(e) => setValue(e.target.value)}
          />
        </form>

        <button
          className="btn btn-netrual mt-4"
          disabled={loading}
          onClick={async () => {
            setLoading(true);
            await handleContribute(value);
            setLoading(false);
          }}
        >
          {loading && <span className="loading loading-spinner"></span>}
          确认
        </button>
      </div>
    </dialog>
  );
}
